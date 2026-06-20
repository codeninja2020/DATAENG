"""
writer.py
---------
Amazon Neptune write layer for the Members ETL pipeline.

Graph model
~~~~~~~~~~~
Vertices
  Member     – one per member row; keyed on ``memberId``.
  Programme  – one per loyalty scheme; keyed on ``schemeId``.
  Location   – one per city; keyed on ``city``.
  Company    – one per company name; keyed on ``companyName``.
  Reference1 – one per Reference1 value; keyed on ``reference1``.

Edges (all directed: Member → related vertex)
  ENROLLED_IN  – Member belongs to a Programme.
  LOCATED_IN   – Member is located in a Location city.
  WORKS_AT     – Member works at a Company.
  HAS_REFERENCE1 – Member has a Reference1 classification.

Upsert semantics
~~~~~~~~~~~~~~~~
Every Gremlin traversal uses the ``fold().coalesce(unfold(), addV/addE)``
pattern, which means:
  * If the vertex / edge already exists it is updated in place.
  * If it does not exist it is created.
This makes the pipeline safely re-runnable (idempotent).

Environment variables
~~~~~~~~~~~~~~~~~~~~~
NEPTUNE_ENDPOINT  (required) Neptune cluster endpoint (no scheme, no port).
NEPTUNE_PORT      (optional) Port to connect on; defaults to ``8182``.
AWS_REGION        (optional) AWS region for SigV4 signing; defaults to
                  ``eu-west-1``.
"""

import os
import logging
from datetime import date, datetime
from typing import Any

import boto3
import requests
from requests_aws4auth import AWS4Auth

log = logging.getLogger(__name__)

# Gremlin traversal templates

# All traversals use the coalesce(unfold, addV/addE) pattern to achieve
# upsert semantics: existing vertices/edges are updated; new ones are created.
# Bindings (passed as a separate ``bindings`` dict to Neptune) keep the
# traversal strings reusable and prevent injection issues.

# Upsert a Member vertex and set all properties in one traversal.
_UPSERT_MEMBER = (
    "g.V().has('Member','memberId',mid)"
    ".fold().coalesce(__.unfold(),__.addV('Member').property('memberId',mid))"
    ".property('name',name)"
    ".property('firstName',firstName)"
    ".property('middleName',middleName)"
    ".property('surname',surname)"
    ".property('dob',dob)"
    ".property('sex',sex)"
    ".property('jobTitle',jobTitle)"
    ".property('companyName',companyName)"
    ".property('goesBy',goesBy)"
    ".property('memberGroupId',memberGroupId)"
    ".property('memberStatusId',memberStatusId)"
    ".property('dateJoined',dateJoined)"
    ".property('dateOfExpiry',dateOfExpiry)"
    ".property('primaryEmail',primaryEmail)"
    ".property('primaryMobile',primaryMobile)"
    ".property('clientRefNo',clientRefNo)"
    ".property('reference1',reference1)"
    ".property('reference2',reference2)"
    ".property('reference3',reference3)"
    ".property('reference5',reference5)"
    ".property('reference6',reference6)"
    ".property('digitalId',digitalId)"
    ".property('salesForceId',salesForceId)"
    ".property('isInvestor',isInvestor)"
    ".property('isMain',isMain)"
    ".property('geoPostcode',geoPostcode)"
    ".property('amadeusProfileId',amadeusProfileId)"
    ".property('ttsCustId',ttsCustId)"
    ".property('foreignMemberId',foreignMemberId)"
)

# Upsert a Programme vertex, then upsert the ENROLLED_IN edge from Member.
_UPSERT_PROGRAMME = (
    "g.V().has('Programme','schemeId',sid)"
    ".fold().coalesce(__.unfold(),__.addV('Programme').property('schemeId',sid))"
    ".as('p')"
    # Navigate to the Member vertex and upsert the ENROLLED_IN edge to 'p'
    ".V().has('Member','memberId',mid)"
    ".coalesce(__.outE('ENROLLED_IN').where(__.inV().as('p')),__.addE('ENROLLED_IN').to('p'))"
)

# Upsert a Reference1 vertex (keyed on reference1 value), with memberId property,
# then upsert a HAS_REFERENCE1 edge from Member → Reference1.
_UPSERT_REFERENCE1 = (
    "g.V().has('Reference1','reference1',ref1)"
    ".fold().coalesce(__.unfold(),__.addV('Reference1').property('reference1',ref1))"
    ".property('memberId',mid)"
    ".as('r')"
    ".V().has('Member','memberId',mid)"
    ".coalesce("
    # Reuse the existing edge if one already points to this Reference1 vertex
    "__.outE('HAS_REFERENCE1').where(__.inV().has('Reference1','reference1',ref1)),"
    "__.addE('HAS_REFERENCE1').to('r')"
    ")"
)

# Upsert a Company vertex (with location/reference1), then upsert WORKS_AT edge.
_UPSERT_COMPANY = (
    "g.V().has('Company','companyName',companyName)"
    ".fold().coalesce(__.unfold(),__.addV('Company').property('companyName',companyName))"
    ".property('location',location)"
    ".property('reference1',reference1)"
    ".as('c')"
    ".V().has('Member','memberId',mid)"
    ".coalesce(__.outE('WORKS_AT').where(__.inV().as('c')),__.addE('WORKS_AT').to('c'))"
)

# Upsert a Location vertex (with postcode/countryId), then upsert LOCATED_IN edge.
_UPSERT_LOCATION = (
    "g.V().has('Location','city',city)"
    ".fold().coalesce(__.unfold(),__.addV('Location').property('city',city))"
    ".property('postcode',postcode)"
    ".property('countryId',countryId)"
    ".as('l')"
    ".V().has('Member','memberId',mid)"
    ".coalesce(__.outE('LOCATED_IN').where(__.inV().as('l')),__.addE('LOCATED_IN').to('l'))"
)


""" Internal helpers """

def _auth() -> AWS4Auth:
    """Build AWS SigV4 authentication credentials for Neptune HTTP requests.

    Fetches short-lived credentials from the current boto3 session (works with
    IAM roles attached to ECS tasks / EC2 instances as well as explicit
    ``AWS_ACCESS_KEY_ID`` / ``AWS_SECRET_ACCESS_KEY`` env vars).

    Returns
    -------
    AWS4Auth
        A ``requests``-compatible auth object that signs every HTTP request
        with AWS Signature Version 4 for the ``neptune-db`` service.
    """
    creds = boto3.Session().get_credentials().get_frozen_credentials()
    return AWS4Auth(
        creds.access_key,
        creds.secret_key,
        os.environ.get("AWS_REGION", "eu-west-1"),
        "neptune-db",
        session_token=creds.token,  # required when using temporary credentials
    )


def _query(gremlin: str, bindings: dict[str, Any] | None = None) -> None:
    """Submit a single Gremlin traversal to Neptune over the REST/HTTP endpoint.

    Parameters
    ----------
    gremlin:
        The Gremlin traversal string, with named placeholders that match
        the keys in ``bindings``.
    bindings:
        Optional mapping of placeholder names to their runtime values.
        Neptune evaluates the traversal with these substituted in, which
        avoids building dynamic query strings and sidesteps injection risks.

    Raises
    ------
    requests.HTTPError
        If Neptune returns a non-2xx status code (raised by
        ``response.raise_for_status()``).
    """
    endpoint = os.environ["NEPTUNE_ENDPOINT"]
    port = os.environ.get("NEPTUNE_PORT", "8182")

    # Build the JSON payload; only include 'bindings' when values were provided
    payload: dict[str, Any] = {"gremlin": gremlin}
    if bindings:
        payload["bindings"] = bindings

    resp = requests.post(
        f"https://{endpoint}:{port}/gremlin",
        json=payload,
        auth=_auth(),
        timeout=30,  # seconds — prevents hung connections from blocking the pipeline
    )
    resp.raise_for_status()


def _s(v: Any) -> Any:
    """Serialise Python types that Neptune doesn't accept natively.

    Neptune's Gremlin HTTP endpoint does not understand Python ``date`` or
    ``datetime`` objects, so they are converted to ISO-8601 strings before
    being placed in a binding dict.  All other types are returned unchanged.

    Parameters
    ----------
    v:
        Any value that may appear as a row property from SQL Server.

    Returns
    -------
    Any
        ISO-8601 string for date/datetime inputs; the original value otherwise.
    """
    if isinstance(v, (date, datetime)):
        return v.isoformat()
    return v


""" Public API """
def ensure_indexes() -> None:
    """Verify that required Neptune indexes exist (no-op in Gremlin mode).

    Amazon Neptune automatically maintains indexes on all vertex and edge
    properties when using the Gremlin interface, so no explicit DDL is needed.
    This function is kept as an explicit pipeline step to:
      1. Provide an early-fail point if Neptune is unreachable (currently
         just logs; could be extended to run a probe query).
      2. Keep ``main.py``'s orchestration self-documenting.
    """
    # Neptune manages indexes automatically in Gremlin mode — nothing to do.
    log.info("Gremlin mode: property indexes are managed automatically by Neptune")


def write_member(row: dict) -> None:
    """Write a single member row from SQL Server into the Neptune graph.

    Fires up to five Gremlin upsert traversals depending on which optional
    fields are populated in ``row``:

    1. **Always**: upsert the ``Member`` vertex with all scalar properties.
    2. **If SchemeID is not None**: upsert ``Programme`` vertex + ``ENROLLED_IN`` edge.
    3. **If GeoCity is not None**: upsert ``Location`` vertex + ``LOCATED_IN`` edge.
    4. **If CompanyName is not None**: upsert ``Company`` vertex + ``WORKS_AT`` edge.
    5. **If Reference1 is not None**: upsert ``Reference1`` vertex + ``HAS_REFERENCE1`` edge.

    All date/datetime values are serialised to ISO-8601 strings via :func:`_s`
    before being passed as Gremlin bindings.

    Parameters
    ----------
    row:
        A dictionary of column_name → value as returned by
        :func:`reader.read_batches`.

    Raises
    ------
    requests.HTTPError
        Propagated from :func:`_query` if Neptune rejects the traversal.
    KeyError
        If ``MemberID`` is missing from ``row`` (should never happen with a
        well-formed Members table, but will surface data quality issues early).
    """
    mid = row["MemberID"]

    # --- 1. Core Member vertex upsert (always executed) ---
    _query(_UPSERT_MEMBER, {
        "mid":              mid,
        "name":             _s(row.get("Name")),
        "firstName":        _s(row.get("FirstName")),
        "middleName":       _s(row.get("MiddleName")),
        "surname":          _s(row.get("Surname")),
        "dob":              _s(row.get("DOB")),
        "sex":              _s(row.get("Sex")),
        "jobTitle":         _s(row.get("JobTitle")),
        "companyName":      _s(row.get("CompanyName")),
        "goesBy":           _s(row.get("GoesBy")),
        "memberGroupId":    row.get("MemberGroupID"),
        "memberStatusId":   row.get("MembershipStatusID"),
        "dateJoined":       _s(row.get("DateJoined")),
        "dateOfExpiry":     _s(row.get("DateOfExpiry")),
        "primaryEmail":     _s(row.get("PrimaryEmail")),
        "primaryMobile":    _s(row.get("PrimaryMobile")),
        "clientRefNo":      _s(row.get("ClientRefNo")),
        "reference1":       _s(row.get("Reference1")),
        "reference2":       _s(row.get("Reference2")),
        "reference3":       _s(row.get("Reference3")),
        "reference5":       _s(row.get("Reference5")),
        "reference6":       _s(row.get("Reference6")),
        "digitalId":        _s(row.get("DigitalId")),
        "salesForceId":     _s(row.get("salesForceID")),
        "isInvestor":       row.get("IsInvestor"),
        "isMain":           row.get("IsMain"),
        "geoPostcode":      _s(row.get("GeoPostcode")),
        "amadeusProfileId": _s(row.get("AmadeusProfileID")),
        "ttsCustId":        row.get("TTSCustomerID"),
        "foreignMemberId":  row.get("ForeignMemberID"),
    })

    # --- 2. Programme vertex + ENROLLED_IN edge (only when SchemeID present) ---
    if row.get("SchemeID") is not None:
        _query(_UPSERT_PROGRAMME, {"mid": mid, "sid": row["SchemeID"]})

    # --- 3. Location vertex + LOCATED_IN edge (only when city is known) ---
    city = row.get("GeoCity")
    if city:
        _query(_UPSERT_LOCATION, {
            "mid":       mid,
            "city":      city,
            "postcode":  _s(row.get("GeoPostcode")),
            "countryId": row.get("CountryID"),
        })

    # --- 4. Company vertex + WORKS_AT edge (only when company name is known) ---
    company = row.get("CompanyName")
    if company:
        _query(_UPSERT_COMPANY, {
            "mid":         mid,
            "companyName": _s(company),
            "location":    _s(row.get("GeoCity")),   # denormalised for quick lookups
            "reference1":  _s(row.get("Reference1")),
        })

    # --- 5. Reference1 vertex + HAS_REFERENCE1 edge (only when ref1 is set) ---
    ref1 = row.get("Reference1")
    if ref1:
        _query(_UPSERT_REFERENCE1, {
            "mid":  mid,
            "ref1": _s(ref1),
        })
