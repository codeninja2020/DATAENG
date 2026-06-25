from typing import List

REQUIRED_COLUMNS: List[str] = [
    "primary_member_reference",
    "secondary_member_reference",
    "primary_programme_reference",
    "membership_status",
    "title_code",
    "first_name",
    "last_name",
    "gender_code",
    "language_code",
    "date_of_birth",
    "address_line_1",
    "address_line_2",
    "town_city",
    "state_region",
    "post_code",
    "country_code",
    "email_address",
    "main_phone",
]

MAX_LENGTHS = {
    # The proposed feed says 10 characters, but its required PrivateBank value is 11.
    "primary_programme_reference": 11,
    "first_name": 100,
    "last_name": 100,
    "gender_code": 1,
    "address_line_1": 100,
    "address_line_2": 100,
    "town_city": 50,
    "state_region": 50,
    "post_code": 50,
    "email_address": 100,
}

EMAIL_REGEX = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
CIN_REGEX = r"^(G\d{10}|\d{10})$"
INTEGER_REGEX = r"^\d+$"
COUNTRY_CODE_REGEX = r"^[A-Z]{2}$"
E164_PHONE_REGEX = r"^\+[1-9]\d{6,14}$"
UK_POSTCODE_REGEX = r"^[A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}$"
DATE_YYYY_MM_DD_REGEX = r"^\d{4}-\d{2}-\d{2}$"

ISO_COUNTRY_CODES = [
    "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AN", "AO", "AQ", "AR", "AS", "AT", "AU", "AW", "AX",
    "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BL", "BM", "BN", "BO", "BR", "BS",
    "BT", "BV", "BW", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN",
    "CO", "CR", "CU", "CV", "CX", "CY", "CZ", "DE", "DJ", "DK", "DM", "DO", "DZ", "EC", "EE", "EG",
    "EH", "ER", "ES", "ET", "FI", "FJ", "FK", "FM", "FO", "FR", "GA", "GB", "GD", "GE", "GF", "GG",
    "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN",
    "HR", "HT", "HU", "ID", "IE", "IL", "IM", "IN", "IO", "IQ", "IR", "IS", "IT", "JE", "JM", "JO",
    "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI",
    "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD", "ME", "MF", "MG", "MH", "MK", "ML",
    "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ", "NA", "NC",
    "NE", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "PA", "PE", "PF", "PG", "PH",
    "PK", "PL", "PM", "PN", "PR", "PS", "PT", "PW", "PY", "QA", "RE", "RO", "RS", "RU", "RW", "SA",
    "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "SS", "ST",
    "SV", "SY", "SZ", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TL", "TM", "TN", "TO", "TR", "TT",
    "TV", "TW", "TZ", "UA", "UG", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU",
    "WF", "WS", "YE", "YT", "ZA", "ZM", "ZW",
]


def _pandas_string_series(series):
    import pandas as pd

    if isinstance(series, pd.DataFrame):
        # Duplicate column names cause df["column"] to return a DataFrame.
        # Coalesce duplicate values from left to right before string handling.
        normalized = series.fillna("").astype(str).apply(
            lambda column: column.str.strip()
        )
        return (
            normalized.replace("", pd.NA)
            .bfill(axis=1)
            .iloc[:, 0]
            .fillna("")
        )
    return series.fillna("").astype(str).str.strip()


def _coalesce_duplicate_columns(df):
    import pandas as pd

    duplicate_names = df.columns[df.columns.duplicated()].unique().tolist()
    if not duplicate_names:
        return df.copy()

    coalesced = pd.DataFrame(index=df.index)
    for column in dict.fromkeys(df.columns):
        values = df.loc[:, df.columns == column]
        coalesced[column] = _pandas_string_series(values)
    return coalesced


def _pandas_regex_matches(series, pattern):
    return _pandas_string_series(series).str.fullmatch(pattern, na=False)


def with_validation_errors_pandas(df):
    import pandas as pd

    checked = _coalesce_duplicate_columns(df)
    errors = []
    reason_codes = []

    for column in REQUIRED_COLUMNS:
        missing = _pandas_string_series(checked[column]).eq("")
        errors.append(missing.map({True: f"{column} is required", False: ""}))
        reason_codes.append(missing.map({
            True: f"REQUIRED_{column.upper()}",
            False: "",
        }))

    checks = [
        (~_pandas_regex_matches(checked["primary_member_reference"], CIN_REGEX), "INVALID_PRIMARY_MEMBER_REFERENCE", "primary_member_reference must be 10 digits or G followed by 10 digits"),
        (~_pandas_regex_matches(checked["email_address"], EMAIL_REGEX), "INVALID_EMAIL_ADDRESS", "email_address is invalid"),
        (~checked["membership_status"].isin(["0", "1"]), "INVALID_MEMBERSHIP_STATUS", "membership_status must be 0 or 1"),
        (~_pandas_regex_matches(checked["title_code"], INTEGER_REGEX), "INVALID_TITLE_CODE", "title_code must be an integer"),
        (~checked["gender_code"].isin(["0", "1", "2", "3", "4"]), "INVALID_GENDER_CODE", "gender_code must be one of 0, 1, 2, 3, or 4"),
        (~checked["primary_programme_reference"].isin(["PrivateBank", "Premier"]), "INVALID_PROGRAMME_REFERENCE", "primary_programme_reference must be PrivateBank or Premier"),
        (~_pandas_regex_matches(checked["date_of_birth"], DATE_YYYY_MM_DD_REGEX), "INVALID_DATE_OF_BIRTH", "date_of_birth must be in YYYY-MM-DD format"),
        (~_pandas_regex_matches(checked["country_code"], COUNTRY_CODE_REGEX), "INVALID_COUNTRY_CODE_FORMAT", "country_code must be a two-letter ISO country code"),
        (~checked["country_code"].isin(ISO_COUNTRY_CODES), "INVALID_COUNTRY_CODE", "country_code must be a valid ISO 3166-1 alpha-2 code"),
        (~_pandas_regex_matches(checked["post_code"], UK_POSTCODE_REGEX), "INVALID_POST_CODE", "post_code must use a valid UK postcode format"),
    ]
    for invalid_mask, code, message in checks:
        errors.append(invalid_mask.map({True: message, False: ""}))
        reason_codes.append(invalid_mask.map({True: code, False: ""}))

    for column, max_length in MAX_LENGTHS.items():
        invalid = _pandas_string_series(checked[column]).str.len().gt(max_length)
        errors.append(invalid.map({
            True: f"{column} must not exceed {max_length} characters",
            False: "",
        }))
        reason_codes.append(invalid.map({
            True: f"MAX_LENGTH_{column.upper()}",
            False: "",
        }))

    for column in ["main_phone", "business_phone", "home_phone"]:
        values = _pandas_string_series(checked[column])
        invalid = values.ne("") & ~_pandas_regex_matches(values, E164_PHONE_REGEX)
        errors.append(invalid.map({
            True: f"{column} must use E.164 format",
            False: "",
        }))
        reason_codes.append(invalid.map({
            True: f"INVALID_{column.upper()}",
            False: "",
        }))

    error_frame = pd.concat(errors, axis=1)
    reason_code_frame = pd.concat(reason_codes, axis=1)
    checked["validation_errors"] = error_frame.apply(
        lambda row: " | ".join(value for value in row if value),
        axis=1,
    )
    checked["validation_reason_codes"] = reason_code_frame.apply(
        lambda row: " | ".join(value for value in row if value),
        axis=1,
    )
    return checked


def split_valid_invalid_pandas(df):
    df = _coalesce_duplicate_columns(df)
    invalid_mask = df["validation_errors"].ne("")
    invalid = df.loc[invalid_mask].copy()
    valid = df.loc[~invalid_mask].drop(
        columns=["validation_errors", "validation_reason_codes"]
    ).copy()
    return valid, invalid


def reject_email_conflicts_pandas(valid_df, target_df):
    import pandas as pd

    valid_df = _coalesce_duplicate_columns(valid_df)
    target_df = _coalesce_duplicate_columns(target_df)

    # Reject all incoming rows when one scheme/email is assigned to multiple
    # incoming member references. Sorting makes the audit output deterministic.
    incoming_email_owners = valid_df.groupby(
        ["email_address", "scheme_id"],
        as_index=False,
        dropna=False,
    )["primary_member_reference"].agg(
        lambda values: "|".join(sorted(set(value for value in values if value)))
    )
    incoming_email_owners = incoming_email_owners.rename(columns={
        "primary_member_reference": "incoming_conflict_references"
    })
    checked_input = valid_df.merge(
        incoming_email_owners,
        on=["email_address", "scheme_id"],
        how="left",
    )
    input_conflict_mask = checked_input["incoming_conflict_references"].str.contains(
        "|",
        regex=False,
        na=False,
    )
    input_conflicts = checked_input.loc[input_conflict_mask].copy()
    input_conflicts["validation_errors"] = (
        "email_address is assigned to multiple members in the input"
    )
    input_conflicts["validation_reason_codes"] = "EMAIL_CONFLICT_INPUT_MEMBERS"
    input_conflicts["conflict_existing_references"] = input_conflicts[
        "incoming_conflict_references"
    ]
    input_conflicts = input_conflicts.drop(columns=["incoming_conflict_references"])
    valid_df = checked_input.loc[~input_conflict_mask].drop(
        columns=["incoming_conflict_references"]
    ).copy()

    required = {"PrimaryEmail", "Reference1", "SchemeID"}
    if not required.issubset(target_df.columns):
        empty = valid_df.iloc[0:0].copy()
        empty["validation_errors"] = ""
        empty["validation_reason_codes"] = ""
        empty["conflict_existing_references"] = ""
        return valid_df, pd.concat(
            [input_conflicts, empty],
            ignore_index=True,
            sort=False,
        )

    existing = target_df[["PrimaryEmail", "Reference1", "SchemeID"]].copy()
    existing["email_address"] = _pandas_string_series(existing["PrimaryEmail"]).str.lower()
    existing["scheme_id"] = pd.to_numeric(
        existing["SchemeID"],
        errors="coerce",
    )
    existing = existing.dropna(subset=["scheme_id"])
    existing["scheme_id"] = existing["scheme_id"].astype("int64")
    existing["existing_primary_member_reference"] = _pandas_string_series(
        existing["Reference1"]
    )
    existing = existing.loc[existing["email_address"].ne(""), [
        "email_address",
        "scheme_id",
        "existing_primary_member_reference",
    ]]
    existing = existing.sort_values(
        ["email_address", "scheme_id", "existing_primary_member_reference"]
    )
    existing = existing.groupby(
        ["email_address", "scheme_id"],
        as_index=False,
        dropna=False,
    )["existing_primary_member_reference"].agg(
        lambda values: "|".join(sorted(set(value for value in values if value)))
    )
    existing = existing.rename(columns={
        "existing_primary_member_reference": "conflict_existing_references"
    })

    checked = valid_df.merge(existing, on=["email_address", "scheme_id"], how="left")
    existing_references = checked["conflict_existing_references"].fillna("")
    owns_email = checked.apply(
        lambda row: row["primary_member_reference"]
        in set(filter(None, str(row["conflict_existing_references"]).split("|"))),
        axis=1,
    )
    conflict_mask = existing_references.ne("") & ~owns_email

    invalid = checked.loc[conflict_mask].copy()
    invalid["validation_errors"] = "email_address already exists for a different member in SQL Server"
    invalid["validation_reason_codes"] = "EMAIL_CONFLICT_EXISTING_MEMBER"
    valid = checked.loc[~conflict_mask].drop(
        columns=["conflict_existing_references"]
    ).copy()
    invalid = pd.concat(
        [input_conflicts, invalid],
        ignore_index=True,
        sort=False,
    )
    return valid, invalid
