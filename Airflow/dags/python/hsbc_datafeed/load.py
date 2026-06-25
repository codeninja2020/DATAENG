from typing import Dict


# Maps dbo.Members column names to their corresponding TEN standard column names.
# Only columns confirmed to exist in the Members table are included here.
# Feed fields with no Members destination are validated but dropped before the write.

MEMBERS_COLUMN_MAPPING: Dict[str, str] = {
    "Reference1": "primary_member_reference",
    "Reference2": "secondary_member_reference",
    "Reference3": "primary_programme_reference",
    "MembershipStatusID": "membership_status",
    "TitleID": "title_code",
    "FirstName": "first_name",
    "MiddleName": "middle_name",
    "Surname": "last_name",
    "Sex": "gender_code",
    "LanguageID": "language_code",
    "DOB": "date_of_birth",
    "GeoCity": "town_city",
    "GeoPostcode": "post_code",
    "CountryID": "country_code",
    "PrimaryMobile": "main_phone",
    "PrimaryEmail": "email_address",
}


def _pandas_string_series(series):
    return series.fillna("").astype(str).str.strip()


def build_members_model_pandas(valid_df, target_df):
    import pandas as pd
    from datetime import datetime, timezone

    members = valid_df.rename(
        columns={value: key for key, value in MEMBERS_COLUMN_MAPPING.items()}
    ).copy()
    members["SchemeID"] = pd.to_numeric(members["scheme_id"], errors="raise").astype(int)
    members["DOB"] = pd.to_datetime(
        members["DOB"],
        format="%Y-%m-%d",
        errors="raise",
    ).dt.date

    existing = target_df[["SchemeID", "Reference1", "DateJoined"]].copy()
    existing["SchemeID"] = pd.to_numeric(existing["SchemeID"], errors="coerce")
    existing["Reference1"] = _pandas_string_series(existing["Reference1"])
    existing = existing.dropna(subset=["SchemeID"]).drop_duplicates(
        ["SchemeID", "Reference1"]
    )

    members = members.merge(existing, on=["SchemeID", "Reference1"], how="left")
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    members["DateJoined"] = pd.to_datetime(
        members["DateJoined"],
        errors="coerce",
    ).fillna(now)
    columns = ["SchemeID", "DateJoined"] + list(MEMBERS_COLUMN_MAPPING.keys())
    return members[columns]


def filter_changed_pandas(members_df, target_df):
    import pandas as pd

    key_columns = ["SchemeID", "Reference1"]
    compare_columns = [
        column
        for column in MEMBERS_COLUMN_MAPPING
        if column in target_df.columns and column not in key_columns
    ]
    existing_columns = key_columns + compare_columns
    existing = target_df[existing_columns].copy()
    existing["SchemeID"] = pd.to_numeric(existing["SchemeID"], errors="coerce")
    existing["Reference1"] = _pandas_string_series(existing["Reference1"])
    existing = existing.dropna(subset=["SchemeID"])
    existing["SchemeID"] = existing["SchemeID"].astype(int)
    existing = existing.drop_duplicates(key_columns)
    existing["_target_row_exists"] = True
    existing = existing.rename(
        columns={column: f"_existing_{column}" for column in compare_columns}
    )

    joined = members_df.merge(existing, on=key_columns, how="left")
    is_new = joined["_target_row_exists"].isna()
    is_changed = pd.Series(False, index=joined.index)
    for column in compare_columns:
        incoming = joined[column].fillna("").astype(str)
        current = joined[f"_existing_{column}"].fillna("").astype(str)
        is_changed |= incoming.ne(current)
    return joined.loc[is_new | is_changed, members_df.columns].copy()
