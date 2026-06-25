-- ================================================================
-- Validation Detail  |  Members table  |  TENMAID_UAT
-- Returns every affected row for each failed validation check.
-- To target a different scheme: replace 1587 with the SchemeID
-- ================================================================
USE TENMAID_UAT
-- Required: MemberID not null
SELECT
    'Required - MemberID must not be null'  AS FailedCheck,
    MemberID,
    'MemberID'                              AS ColumnName,
    CAST(MemberID AS NVARCHAR(255))         AS ColumnValue
FROM dbo.Members
WHERE SchemeID = 1587
  AND MemberID IS NULL

UNION ALL

-- Required: FirstName not null / not blank
SELECT
    'Required - FirstName must not be null or blank',
    MemberID,
    'FirstName',
    FirstName
FROM dbo.Members
WHERE SchemeID = 1587
  AND (FirstName IS NULL OR LTRIM(RTRIM(FirstName)) = '')

UNION ALL

-- Required: Surname not null / not blank
SELECT
    'Required - Surname must not be null or blank',
    MemberID,
    'Surname',
    Surname
FROM dbo.Members
WHERE SchemeID = 1587
  AND (Surname IS NULL OR LTRIM(RTRIM(Surname)) = '')

UNION ALL

-- Required: PrimaryEmail not null / not blank
SELECT
    'Required - PrimaryEmail must not be null or blank',
    MemberID,
    'PrimaryEmail',
    PrimaryEmail
FROM dbo.Members
WHERE SchemeID = 1587
  AND (PrimaryEmail IS NULL OR LTRIM(RTRIM(PrimaryEmail)) = '')

UNION ALL

-- Required: TitleID not null
SELECT
    'Required - TitleID must not be null',
    MemberID,
    'TitleID',
    CAST(TitleID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND TitleID IS NULL

UNION ALL

-- Required: Sex not null / not blank
SELECT
    'Required - Sex must not be null or blank',
    MemberID,
    'Sex',
    CAST(Sex AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND (Sex IS NULL OR LTRIM(RTRIM(Sex)) = '')

UNION ALL

-- Required: MembershipStatusID not null
SELECT
    'Required - MembershipStatusID must not be null',
    MemberID,
    'MembershipStatusID',
    CAST(MembershipStatusID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND MembershipStatusID IS NULL

UNION ALL

-- Required: CountryID not null / not blank
SELECT
    'Required - CountryID must not be null or blank',
    MemberID,
    'CountryID',
    CAST(CountryID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND (CountryID IS NULL OR LTRIM(RTRIM(CountryID)) = '')

UNION ALL

-- Required: Reference1 (primary member reference), Reference2 (secondary member reference), Reference3 (primary programme reference)
SELECT 'Required - Reference1 (Primary member reference) must not be null',    MemberID, 'Reference1', Reference1 FROM dbo.Members WHERE SchemeID = 1587 AND (Reference1 IS NULL OR LTRIM(RTRIM(Reference1)) = '') UNION ALL
SELECT 'Required - Reference2 (Secondary member reference) must not be null',  MemberID, 'Reference2', Reference2 FROM dbo.Members WHERE SchemeID = 1587 AND (Reference2 IS NULL OR LTRIM(RTRIM(Reference2)) = '') UNION ALL
SELECT 'Required - Reference3 (Primary programme reference) must not be null', MemberID, 'Reference3', Reference3 FROM dbo.Members WHERE SchemeID = 1587 AND (Reference3 IS NULL OR LTRIM(RTRIM(Reference3)) = '') UNION ALL
SELECT 'Required - LanguageID must not be null',                               MemberID, 'LanguageID', LanguageID FROM dbo.Members WHERE SchemeID = 1587 AND (LanguageID IS NULL OR LTRIM(RTRIM(LanguageID)) = '') UNION ALL
SELECT 'Required - DOB must not be null',         MemberID, 'DOB',         CAST(DOB AS NVARCHAR(50)) FROM dbo.Members WHERE SchemeID = 1587 AND DOB IS NULL UNION ALL
SELECT 'Required - GeoCity must not be null',     MemberID, 'GeoCity',     GeoCity                   FROM dbo.Members WHERE SchemeID = 1587 AND (GeoCity    IS NULL OR LTRIM(RTRIM(GeoCity))    = '') UNION ALL
SELECT 'Required - GeoPostcode must not be null', MemberID, 'GeoPostcode', GeoPostcode               FROM dbo.Members WHERE SchemeID = 1587 AND (GeoPostcode IS NULL OR LTRIM(RTRIM(GeoPostcode)) = '')

UNION ALL

-- Format: address fields must not exceed 50 characters
SELECT 'Format - GeoPostcode exceeds 50 characters', MemberID, 'GeoPostcode', GeoPostcode FROM dbo.Members WHERE SchemeID = 1587 AND GeoPostcode IS NOT NULL AND LEN(GeoPostcode) > 50 UNION ALL
SELECT 'Format - GeoCity exceeds 50 characters',     MemberID, 'GeoCity',     GeoCity     FROM dbo.Members WHERE SchemeID = 1587 AND GeoCity     IS NOT NULL AND LEN(GeoCity)     > 50

UNION ALL

-- Format: name fields must not exceed 100 characters
SELECT 'Format - FirstName exceeds 100 characters',  MemberID, 'FirstName',  FirstName  FROM dbo.Members WHERE SchemeID = 1587 AND FirstName  IS NOT NULL AND LEN(FirstName)  > 100 UNION ALL
SELECT 'Format - MiddleName exceeds 100 characters', MemberID, 'MiddleName', MiddleName FROM dbo.Members WHERE SchemeID = 1587 AND MiddleName IS NOT NULL AND LEN(MiddleName) > 100 UNION ALL
SELECT 'Format - Surname exceeds 100 characters',    MemberID, 'Surname',    Surname    FROM dbo.Members WHERE SchemeID = 1587 AND Surname    IS NOT NULL AND LEN(Surname)    > 100

UNION ALL

-- Format: email must match WHATWG HTML standard
-- ^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
SELECT
    'Format - PrimaryEmail invalid format',
    MemberID,
    'PrimaryEmail',
    PrimaryEmail
FROM dbo.Members
WHERE SchemeID = 1587
  AND PrimaryEmail IS NOT NULL
  AND (
      PrimaryEmail NOT LIKE '%_@_%.__%'
      OR PrimaryEmail LIKE '% %'
      OR PrimaryEmail LIKE '@%'
      OR PrimaryEmail LIKE '%@'
  )

UNION ALL

-- Format: email must not exceed 100 characters
SELECT
    'Format - PrimaryEmail exceeds 100 characters',
    MemberID,
    'PrimaryEmail',
    PrimaryEmail
FROM dbo.Members
WHERE SchemeID = 1587
  AND PrimaryEmail IS NOT NULL
  AND LEN(PrimaryEmail) > 100

UNION ALL

-- Format: phone number must not exceed 15 characters
SELECT
    'Format - PrimaryMobile exceeds 15 characters',
    MemberID,
    'PrimaryMobile',
    PrimaryMobile
FROM dbo.Members
WHERE SchemeID = 1587
  AND PrimaryMobile IS NOT NULL
  AND LEN(PrimaryMobile) > 15

UNION ALL

-- Format: phone number must be E.164 format (+ followed by 7-15 digits)
SELECT
    'Format - PrimaryMobile invalid E.164 format',
    MemberID,
    'PrimaryMobile',
    PrimaryMobile
FROM dbo.Members
WHERE SchemeID = 1587
  AND PrimaryMobile IS NOT NULL
  AND (
      PrimaryMobile NOT LIKE '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
      OR LEN(REPLACE(PrimaryMobile, '+', '')) NOT BETWEEN 7 AND 15
      OR PrimaryMobile LIKE '%[^0-9+]%'
  )

UNION ALL

-- Format: CountryID must be exactly 2 characters (ISO 3166-1 alpha-2)
SELECT
    'Format - CountryID must be 2 characters',
    MemberID,
    'CountryID',
    CAST(CountryID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND CountryID IS NOT NULL
  AND LEN(LTRIM(RTRIM(CountryID))) <> 2

UNION ALL

-- Format: CountryID must be a valid ISO 3166-1 alpha-2 code (when present)
SELECT
    'Format - CountryID invalid ISO 3166-1 alpha-2 code',
    MemberID,
    'CountryID',
    CAST(CountryID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND CountryID IS NOT NULL
  AND UPPER(LTRIM(RTRIM(CountryID))) NOT IN (
    'AF','AX','AL','DZ','AS','AD','AO','AI','AQ','AG','AR','AM','AW','AU','AT',
    'AZ','BS','BH','BD','BB','BY','BE','BZ','BJ','BM','BT','BO','BA','BW','BV',
    'BR','IO','BN','BG','BF','BI','KH','CM','CA','CV','KY','CF','TD','CL','CN',
    'CX','CC','CO','KM','CG','CD','CK','CR','CI','HR','CU','CY','CZ','DK','DJ',
    'DM','DO','EC','EG','SV','GQ','ER','EE','ET','FK','FO','FJ','FI','FR','GF',
    'PF','TF','GA','GM','GE','DE','GH','GI','GR','GL','GD','GP','GU','GT','GG',
    'GN','GW','GY','HT','HM','VA','HN','HK','HU','IS','IN','ID','IR','IQ','IE',
    'IM','IL','IT','JM','JP','JE','JO','KZ','KE','KI','KP','KR','KW','KG','LA',
    'LV','LB','LS','LR','LY','LI','LT','LU','MO','MK','MG','MW','MY','MV','ML',
    'MT','MH','MQ','MR','MU','YT','MX','FM','MD','MC','MN','ME','MS','MA','MZ',
    'MM','NA','NR','NP','NL','AN','NC','NZ','NI','NE','NG','NU','NF','MP','NO',
    'OM','PK','PW','PS','PA','PG','PY','PE','PH','PN','PL','PT','PR','QA','RE',
    'RO','RU','RW','BL','SH','KN','LC','MF','PM','VC','WS','SM','ST','SA','SN',
    'RS','SC','SL','SG','SK','SI','SB','SO','ZA','GS','SS','ES','LK','SD','SR',
    'SJ','SZ','SE','CH','SY','TW','TJ','TZ','TH','TL','TG','TK','TO','TT','TN',
    'TR','TM','TC','TV','UG','UA','AE','GB','US','UM','UY','UZ','VU','VE','VN',
    'VG','VI','WF','EH','YE','ZM','ZW')

UNION ALL

-- Format: UK postcode format
SELECT
    'Format - GeoPostcode invalid UK postcode format',
    MemberID,
    'GeoPostcode',
    GeoPostcode
FROM dbo.Members
WHERE SchemeID = 1587
  AND GeoPostcode IS NOT NULL
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9] [0-9][A-Z][A-Z]'
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9][0-9] [0-9][A-Z][A-Z]'
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9] [0-9][A-Z][A-Z]'
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9][0-9] [0-9][A-Z][A-Z]'
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9][A-Z] [0-9][A-Z][A-Z]'
  AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9][A-Z] [0-9][A-Z][A-Z]'

UNION ALL

-- Name Case: FirstName must be Title Case
SELECT
    'Name Case - FirstName must be Title Case',
    MemberID,
    'FirstName',
    FirstName
FROM dbo.Members
WHERE SchemeID = 1587
  AND FirstName IS NOT NULL
  AND LTRIM(RTRIM(FirstName)) <> ''
  AND (
      FirstName LIKE '[a-z]%'          COLLATE Latin1_General_CS_AS
      OR (FirstName NOT LIKE '%[a-z]%' COLLATE Latin1_General_CS_AS
          AND FirstName LIKE '%[A-Z]%' COLLATE Latin1_General_CS_AS)
  )

UNION ALL

-- Name Case: Surname must be Title Case
SELECT
    'Name Case - Surname must be Title Case',
    MemberID,
    'Surname',
    Surname
FROM dbo.Members
WHERE SchemeID = 1587
  AND Surname IS NOT NULL
  AND LTRIM(RTRIM(Surname)) <> ''
  AND (
      Surname LIKE '[a-z]%'          COLLATE Latin1_General_CS_AS
      OR (Surname NOT LIKE '%[a-z]%' COLLATE Latin1_General_CS_AS
          AND Surname LIKE '%[A-Z]%' COLLATE Latin1_General_CS_AS)
  )

UNION ALL

-- Uniqueness: duplicate PrimaryEmail within scheme
SELECT
    'Uniqueness - Duplicate PrimaryEmail',
    MemberID,
    'PrimaryEmail',
    PrimaryEmail
FROM dbo.Members
WHERE SchemeID = 1587
  AND PrimaryEmail IN (
      SELECT PrimaryEmail
      FROM dbo.Members
      WHERE SchemeID = 1587
        AND PrimaryEmail IS NOT NULL
      GROUP BY PrimaryEmail
      HAVING COUNT(*) > 1
  )

UNION ALL

-- Uniqueness: duplicate MemberID within scheme
SELECT
    'Uniqueness - Duplicate MemberID',
    MemberID,
    'MemberID',
    CAST(MemberID AS NVARCHAR(255))
FROM dbo.Members
WHERE SchemeID = 1587
  AND MemberID IN (
      SELECT MemberID
      FROM dbo.Members
      WHERE SchemeID = 1587
      GROUP BY MemberID
      HAVING COUNT(*) > 1
  )

ORDER BY
    FailedCheck,
    MemberID;
