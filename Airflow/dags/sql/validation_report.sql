-- ================================================================
-- Validation Report  |  Members table  |  TENMAID_UAT
-- Returns one summary row per validation check for a target scheme.
-- To target
-- a different scheme: change @SchemeID.
-- ================================================================

USE TENMAID_UAT;

DECLARE @SchemeID INT = 1597 ; --, 2378 1587;
DECLARE @RunDate  DATETIME = GETDATE();

WITH Members AS (
    SELECT *
    FROM dbo.Members
    WHERE SchemeID = @SchemeID
),

Totals AS (
    SELECT COUNT(*) AS TotalRecords
    FROM Members
),

Checks AS (
    SELECT
        1 AS CheckID,
        @SchemeID AS SchemeID,
        'Required' AS Category,
        'CountryID' AS ColumnName,
        'Must not be null or blank' AS val_rule,
        COUNT(*) AS ViolationCount
    FROM Members
    WHERE CountryID IS NULL OR LTRIM(RTRIM(CountryID)) = ''

    UNION ALL

    SELECT 2, @SchemeID, 'Required', 'DOB', 'Date of birth must not be null', COUNT(*)
    FROM Members
    WHERE DOB IS NULL

    UNION ALL

    SELECT 3, @SchemeID, 'Required', 'FirstName', 'Must not be null or blank', COUNT(*)
    FROM Members
    WHERE FirstName IS NULL OR LTRIM(RTRIM(FirstName)) = ''

    UNION ALL

    SELECT 4, @SchemeID, 'Required', 'GeoCity', 'Town/city must not be null or blank', COUNT(*)
    FROM Members
    WHERE GeoCity IS NULL OR LTRIM(RTRIM(GeoCity)) = ''

    UNION ALL

    SELECT 5, @SchemeID, 'Required', 'GeoPostcode', 'Postcode must not be null or blank', COUNT(*)
    FROM Members
    WHERE GeoPostcode IS NULL OR LTRIM(RTRIM(GeoPostcode)) = ''

    UNION ALL

    SELECT 6, @SchemeID, 'Required', 'LanguageID', 'Language code must not be null', COUNT(*)
    FROM Members
    WHERE LanguageID IS NULL OR LTRIM(RTRIM(LanguageID)) = ''

    UNION ALL

    SELECT 7, @SchemeID, 'Required', 'MemberID', 'Must not be null', COUNT(*)
    FROM Members
    WHERE MemberID IS NULL

    UNION ALL

    SELECT 8, @SchemeID, 'Required', 'MembershipStatusID', 'Must not be null', COUNT(*)
    FROM Members
    WHERE MembershipStatusID IS NULL

    UNION ALL

    SELECT 9, @SchemeID, 'Required', 'PrimaryEmail', 'Must not be null or blank', COUNT(*)
    FROM Members
    WHERE PrimaryEmail IS NULL OR LTRIM(RTRIM(PrimaryEmail)) = ''

    UNION ALL

    SELECT 10, @SchemeID, 'Required', 'Reference1', 'Primary member reference must not be null', COUNT(*)
    FROM Members
    WHERE Reference1 IS NULL OR LTRIM(RTRIM(Reference1)) = ''

    UNION ALL

    SELECT 11, @SchemeID, 'Required', 'Reference2', 'Secondary member reference must not be null', COUNT(*)
    FROM Members
    WHERE Reference2 IS NULL OR LTRIM(RTRIM(Reference2)) = ''

    UNION ALL

    SELECT 12, @SchemeID, 'Required', 'Sex', 'Must not be null or blank', COUNT(*)
    FROM Members
    WHERE Sex IS NULL OR LTRIM(RTRIM(Sex)) = ''

    UNION ALL

    SELECT 13, @SchemeID, 'Required', 'Surname', 'Must not be null or blank', COUNT(*)
    FROM Members
    WHERE Surname IS NULL OR LTRIM(RTRIM(Surname)) = ''

    UNION ALL

    SELECT 14, @SchemeID, 'Required', 'TitleID', 'Must not be null', COUNT(*)
    FROM Members
    WHERE TitleID IS NULL

    UNION ALL

    SELECT 15, @SchemeID, 'Format', 'CountryID', 'Must be exactly 2 characters (ISO alpha-2)', COUNT(*)
    FROM Members
    WHERE CountryID IS NOT NULL
      AND LEN(LTRIM(RTRIM(CountryID))) <> 2

    UNION ALL

    SELECT 16, @SchemeID, 'Format', 'CountryID', 'Must be a valid ISO 3166-1 alpha-2 code', COUNT(*)
    FROM Members
    WHERE CountryID IS NOT NULL
      AND UPPER(LTRIM(RTRIM(CountryID))) NOT IN (
        'AF','AX','AL','DZ','AS','AD','AO','AI','AQ','AG','AR','AM','AW','AU','AT',
        'AZ','BS','BH','BD','BB','BY','BE','BZ','BJ','BM','BT','BO','BA','BW','BV',
        'BR','IO','BN','BG','BF','BI','KH','CM','CA','CV','KY','CF','TD','CL','CN',
        'CX','CC','CO','KM','CG','CD','CK','CR','CI','HR','CU','CY','CZ','DK','DJ',
        'DM','DO','EC','EG','SV','GQ','ER','EE','ET','FK','FO','FJ','FI','FR','GF',
        'PF','TF','GA','GM','GE','DE','GH','GI','GR','GL','GD','GP','GU','GT','GG',
        'GN','GW','GY','HT','HM','VA','HN','HK','HU','IS','IN','ID','IR','IQ','IE',
        'IM','IL','IT','JM','JP','JE','JO','KZ','KE','KI','KP','KR','KW','KG',
        'LA','LV','LB','LS','LR','LY','LI','LT','LU','MO','MK','MG','MW','MY','MV',
        'ML','MT','MH','MQ','MR','MU','YT','MX','FM','MD','MC','MN','ME','MS','MA',
        'MZ','MM','NA','NR','NP','NL','AN','NC','NZ','NI','NE','NG','NU','NF','MP',
        'NO','OM','PK','PW','PS','PA','PG','PY','PE','PH','PN','PL','PT','PR','QA',
        'RE','RO','RU','RW','BL','SH','KN','LC','MF','PM','VC','WS','SM','ST','SA',
        'SN','RS','SC','SL','SG','SK','SI','SB','SO','ZA','GS','SS','ES','LK','SD',
        'SR','SJ','SZ','SE','CH','SY','TW','TJ','TZ','TH','TL','TG','TK','TO','TT',
        'TN','TR','TM','TC','TV','UG','UA','AE','GB','US','UM','UY','UZ','VU','VE',
        'VN','VG','VI','WF','EH','YE','ZM','ZW')

    UNION ALL

    SELECT 17, @SchemeID, 'Format', 'FirstName', 'Must not exceed 100 characters', COUNT(*)
    FROM Members
    WHERE FirstName IS NOT NULL
      AND LEN(FirstName) > 100

    UNION ALL

    SELECT 18, @SchemeID, 'Format', 'GeoCity', 'Must not exceed 50 characters', COUNT(*)
    FROM Members
    WHERE GeoCity IS NOT NULL
      AND LEN(GeoCity) > 50

    UNION ALL

    SELECT 19, @SchemeID, 'Format', 'GeoPostcode', 'Must match UK postcode format', COUNT(*)
    FROM Members
    WHERE GeoPostcode IS NOT NULL
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9] [0-9][A-Z][A-Z]'
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9][0-9] [0-9][A-Z][A-Z]'
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9] [0-9][A-Z][A-Z]'
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9][0-9] [0-9][A-Z][A-Z]'
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][0-9][A-Z] [0-9][A-Z][A-Z]'
      AND UPPER(LTRIM(RTRIM(GeoPostcode))) NOT LIKE '[A-Z][A-Z][0-9][A-Z] [0-9][A-Z][A-Z]'

    UNION ALL

    SELECT 20, @SchemeID, 'Format', 'GeoPostcode', 'Must not exceed 50 characters', COUNT(*)
    FROM Members
    WHERE GeoPostcode IS NOT NULL
      AND LEN(GeoPostcode) > 50

    UNION ALL

    SELECT 21, @SchemeID, 'Format', 'MiddleName', 'Must not exceed 100 characters', COUNT(*)
    FROM Members
    WHERE MiddleName IS NOT NULL
      AND LEN(MiddleName) > 100

    UNION ALL

    SELECT 22, @SchemeID, 'Format', 'PrimaryEmail', 'Must match WHATWG HTML email standard', COUNT(*)
    FROM Members
    WHERE PrimaryEmail IS NOT NULL
      AND (
          PrimaryEmail NOT LIKE '%_@_%.__%'
          OR PrimaryEmail LIKE '% %'
          OR PrimaryEmail LIKE '@%'
          OR PrimaryEmail LIKE '%@'
      )

    UNION ALL

    SELECT 23, @SchemeID, 'Format', 'PrimaryEmail', 'Must not exceed 100 characters', COUNT(*)
    FROM Members
    WHERE PrimaryEmail IS NOT NULL
      AND LEN(PrimaryEmail) > 100

    UNION ALL

    SELECT 24, @SchemeID, 'Format', 'PrimaryMobile', 'Must not exceed 15 characters', COUNT(*)
    FROM Members
    WHERE PrimaryMobile IS NOT NULL
      AND LEN(PrimaryMobile) > 15

    UNION ALL

    SELECT 25, @SchemeID, 'Format', 'PrimaryMobile', 'Must be E.164 format (+7-15 digits)', COUNT(*)
    FROM Members
    WHERE PrimaryMobile IS NOT NULL
      AND (
          PrimaryMobile NOT LIKE '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
          OR LEN(REPLACE(PrimaryMobile, '+', '')) NOT BETWEEN 7 AND 15
          OR PrimaryMobile LIKE '%[^0-9+]%'
      )

    UNION ALL

    SELECT 26, @SchemeID, 'Format', 'Surname', 'Must not exceed 100 characters', COUNT(*)
    FROM Members
    WHERE Surname IS NOT NULL
      AND LEN(Surname) > 100

    UNION ALL

    SELECT 27, @SchemeID, 'Name Case', 'FirstName', 'Must be Title Case', COUNT(*)
    FROM Members
    WHERE FirstName IS NOT NULL
      AND LTRIM(RTRIM(FirstName)) <> ''
      AND (
          FirstName LIKE '[a-z]%' COLLATE Latin1_General_CS_AS
          OR (FirstName NOT LIKE '%[a-z]%' COLLATE Latin1_General_CS_AS
              AND FirstName LIKE '%[A-Z]%' COLLATE Latin1_General_CS_AS)
      )

    UNION ALL

    SELECT 28, @SchemeID, 'Name Case', 'Surname', 'Must be Title Case', COUNT(*)
    FROM Members
    WHERE Surname IS NOT NULL
      AND LTRIM(RTRIM(Surname)) <> ''
      AND (
          Surname LIKE '[a-z]%' COLLATE Latin1_General_CS_AS
          OR (Surname NOT LIKE '%[a-z]%' COLLATE Latin1_General_CS_AS
              AND Surname LIKE '%[A-Z]%' COLLATE Latin1_General_CS_AS)
      )

    UNION ALL

    SELECT 29, @SchemeID, 'Uniqueness', 'MemberID', 'No duplicate MemberIDs within scheme', COUNT(*)
    FROM Members m
    WHERE m.MemberID IS NOT NULL
      AND EXISTS (
          SELECT 1
          FROM Members d
          WHERE d.MemberID = m.MemberID
          GROUP BY d.MemberID
          HAVING COUNT(*) > 1
      )

    UNION ALL

    SELECT 30, @SchemeID, 'Uniqueness', 'PrimaryEmail', 'No duplicate emails within scheme', COUNT(*)
    FROM Members m
    WHERE m.PrimaryEmail IS NOT NULL
      AND EXISTS (
          SELECT 1
          FROM Members d
          WHERE d.PrimaryEmail = m.PrimaryEmail
          GROUP BY d.PrimaryEmail
          HAVING COUNT(*) > 1
      )

    UNION ALL

    SELECT 31, @SchemeID, 'Required', 'Reference3', 'Primary programme reference must not be null', COUNT(*)
    FROM Members
    WHERE Reference3 IS NULL OR LTRIM(RTRIM(Reference3)) = ''
)

SELECT
    c.CheckID,
    c.SchemeID,
    c.Category,
    c.ColumnName,
    c.val_rule,
    c.ViolationCount,
    t.TotalRecords,
    CAST(
        100.0 * (1 - (1.0 * c.ViolationCount / NULLIF(t.TotalRecords, 0)))
        AS DECIMAL(5,2)
    ) AS PassRate_Pct,
    CASE WHEN c.ViolationCount = 0 THEN 'PASS' ELSE 'FAIL' END AS Status,
    @RunDate AS RunDate
FROM Checks c
CROSS JOIN Totals t
ORDER BY
    CASE WHEN c.ViolationCount > 0 THEN 0 ELSE 1 END,
    c.CheckID;
