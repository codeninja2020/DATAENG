/* ============================================================================
   Repeatable migration: R__HSBC_ETL_validate_load_datafeed.sql

   Purpose: Validate and load from HSBC_ETL.rawdatafeed into HSBC_ETL.tempmembers
            using the Python ETL rules as the source pattern.

   Tables updated:
     - HSBC_ETL.datafeederrors

   Stored procedures updated:
     - HSBC_ETL.Validate_And_Load_Datafeed_To_TempMembers
============================================================================ */

USE TENMAID_UAT;
GO

-- Step 1: Ensure the HSBC_ETL schema exists before creating the procedure.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

CREATE OR ALTER PROCEDURE HSBC_ETL.Validate_And_Load_Datafeed_To_TempMembers
    @PrivateBankSchemeID INT,
    @PremierSchemeID INT,
    @ProcessId VARCHAR(36) = NULL,
    @ClearPreviousRejects BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Step 1: Validate the required scheme mapping parameters.
    IF @PrivateBankSchemeID IS NULL OR @PremierSchemeID IS NULL
        THROW 50200, 'PrivateBank and Premier SchemeID values are required.', 1;

    -- Step 2: Confirm all source, reference, and target tables are available.
    IF OBJECT_ID(N'HSBC_ETL.rawdatafeed', N'U') IS NULL
        THROW 50201, 'HSBC_ETL.rawdatafeed does not exist.', 1;

    IF OBJECT_ID(N'HSBC_ETL.ucodes', N'U') IS NULL
        THROW 50203, 'HSBC_ETL.ucodes does not exist.', 1;

    IF OBJECT_ID(N'HSBC_ETL.datafeederrors', N'U') IS NULL
        THROW 50204, 'HSBC_ETL.datafeederrors does not exist.', 1;

    IF OBJECT_ID(N'HSBC_ETL.tempmembers', N'U') IS NULL
        THROW 50202, 'HSBC_ETL.tempmembers does not exist.', 1;

    -- Step 3: Create the process id used to tag rejects for this validation run.
    SET @ProcessId = ISNULL(@ProcessId, CONVERT(VARCHAR(36), NEWID()));

    -- Step 4: Optionally clear prior reject records so this run has a clean error table.
    IF @ClearPreviousRejects = 1
        DELETE FROM HSBC_ETL.datafeederrors;

    -- Step 5: Drop any leftover temp tables from a prior failed execution in this session.
    IF OBJECT_ID('tempdb..#mapped') IS NOT NULL DROP TABLE #mapped;
    IF OBJECT_ID('tempdb..#rejected') IS NOT NULL DROP TABLE #rejected;
    IF OBJECT_ID('tempdb..#valid') IS NOT NULL DROP TABLE #valid;
    IF OBJECT_ID('tempdb..#members_model') IS NOT NULL DROP TABLE #members_model;
    IF OBJECT_ID('tempdb..#changed_members') IS NOT NULL DROP TABLE #changed_members;

    -- Step 6: Normalize raw feed values and resolve HSBC ucode values to programme names and SchemeID values.
    SELECT
        d.id AS datafeed_id,
        UPPER(LTRIM(RTRIM(ISNULL(d.CIN, N'')))) AS primary_member_reference,
        LTRIM(RTRIM(ISNULL(d.segment, N''))) AS secondary_member_reference,
        UPPER(LTRIM(RTRIM(ISNULL(d.scheme_name, N'')))) AS ucode,
        ISNULL(uc.scheme_name, N'') AS primary_programme_reference,
        LTRIM(RTRIM(ISNULL(d.membership_status, N''))) AS membership_status,
        LTRIM(RTRIM(ISNULL(d.title_code, N''))) AS title_code,
        LTRIM(RTRIM(ISNULL(d.first_name, N''))) AS first_name,
        CAST(N'' AS NVARCHAR(200)) AS middle_name,
        LTRIM(RTRIM(ISNULL(d.last_name, N''))) AS last_name,
        LTRIM(RTRIM(ISNULL(d.gender_code, N''))) AS gender_code,
        LTRIM(RTRIM(ISNULL(d.language_code, N''))) AS language_code,
        LTRIM(RTRIM(ISNULL(d.date_of_birth, N''))) AS date_of_birth,
        LTRIM(RTRIM(ISNULL(d.address_line_1, N''))) AS address_line_1,
        LTRIM(RTRIM(ISNULL(d.address_line_2, N''))) AS address_line_2,
        LTRIM(RTRIM(ISNULL(d.town_city, N''))) AS town_city,
        LTRIM(RTRIM(ISNULL(d.state_region, N''))) AS state_region,
        LTRIM(RTRIM(ISNULL(d.post_code, N''))) AS post_code,
        UPPER(LTRIM(RTRIM(ISNULL(d.country_code, N'')))) AS country_code,
        LOWER(LTRIM(RTRIM(ISNULL(d.email_address, N'')))) AS email_address,
        REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(d.main_phone, N''))), N' ', N''), CHAR(9), N''), CHAR(13), N'') AS main_phone,
        REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(d.business_phone, N''))), N' ', N''), CHAR(9), N''), CHAR(13), N'') AS business_phone,
        REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(d.home_phone, N''))), N' ', N''), CHAR(9), N''), CHAR(13), N'') AS home_phone,
        CASE
            WHEN uc.scheme_name = N'PrivateBank' THEN @PrivateBankSchemeID
            WHEN uc.scheme_name = N'Premier' THEN @PremierSchemeID
            ELSE NULL
        END AS scheme_id,
        d.CIN,
        d.segment,
        d.scheme_name AS raw_scheme_name,
        d.membership_status AS raw_membership_status,
        d.title_code AS raw_title_code,
        d.first_name AS raw_first_name,
        d.last_name AS raw_last_name,
        d.gender_code AS raw_gender_code,
        d.language_code AS raw_language_code,
        d.date_of_birth AS raw_date_of_birth,
        d.address_line_1 AS raw_address_line_1,
        d.address_line_2 AS raw_address_line_2,
        d.town_city AS raw_town_city,
        d.state_region AS raw_state_region,
        d.post_code AS raw_post_code,
        d.country_code AS raw_country_code,
        d.email_address AS raw_email_address,
        d.main_phone AS raw_main_phone,
        d.business_phone AS raw_business_phone,
        d.home_phone AS raw_home_phone
    INTO #mapped
    FROM HSBC_ETL.rawdatafeed d
    LEFT JOIN HSBC_ETL.ucodes uc
        ON uc.ucode = UPPER(LTRIM(RTRIM(ISNULL(d.scheme_name, N''))));

    -- Step 7: Evaluate field-level validation rules and build reason codes for failing rows.
    SELECT
        m.*,
        LTRIM(RTRIM(CONCAT(
            CASE WHEN m.primary_member_reference = N'' THEN N' | REQUIRED_PRIMARY_MEMBER_REFERENCE' ELSE N'' END,
            CASE WHEN m.secondary_member_reference = N'' THEN N' | REQUIRED_SECONDARY_MEMBER_REFERENCE' ELSE N'' END,
            CASE WHEN m.ucode = N'' THEN N' | REQUIRED_UCODE' ELSE N'' END,
            CASE WHEN m.membership_status = N'' THEN N' | REQUIRED_MEMBERSHIP_STATUS' ELSE N'' END,
            CASE WHEN m.title_code = N'' THEN N' | REQUIRED_TITLE_CODE' ELSE N'' END,
            CASE WHEN m.first_name = N'' THEN N' | REQUIRED_FIRST_NAME' ELSE N'' END,
            CASE WHEN m.last_name = N'' THEN N' | REQUIRED_LAST_NAME' ELSE N'' END,
            CASE WHEN m.gender_code = N'' THEN N' | REQUIRED_GENDER_CODE' ELSE N'' END,
            CASE WHEN m.language_code = N'' THEN N' | REQUIRED_LANGUAGE_CODE' ELSE N'' END,
            CASE WHEN m.date_of_birth = N'' THEN N' | REQUIRED_DATE_OF_BIRTH' ELSE N'' END,
            CASE WHEN m.address_line_1 = N'' THEN N' | REQUIRED_ADDRESS_LINE_1' ELSE N'' END,
            CASE WHEN m.address_line_2 = N'' THEN N' | REQUIRED_ADDRESS_LINE_2' ELSE N'' END,
            CASE WHEN m.town_city = N'' THEN N' | REQUIRED_TOWN_CITY' ELSE N'' END,
            CASE WHEN m.state_region = N'' THEN N' | REQUIRED_STATE_REGION' ELSE N'' END,
            CASE WHEN m.post_code = N'' THEN N' | REQUIRED_POST_CODE' ELSE N'' END,
            CASE WHEN m.country_code = N'' THEN N' | REQUIRED_COUNTRY_CODE' ELSE N'' END,
            CASE WHEN m.email_address = N'' THEN N' | REQUIRED_EMAIL_ADDRESS' ELSE N'' END,
            CASE WHEN m.main_phone = N'' THEN N' | REQUIRED_MAIN_PHONE' ELSE N'' END,
            CASE
                WHEN NOT
                (
                    (LEN(m.primary_member_reference) = 10 AND m.primary_member_reference NOT LIKE N'%[^0-9]%')
                    OR
                    (LEN(m.primary_member_reference) = 11 AND LEFT(m.primary_member_reference, 1) = N'G'
                        AND SUBSTRING(m.primary_member_reference, 2, 10) NOT LIKE N'%[^0-9]%')
            )
                THEN N' | INVALID_PRIMARY_MEMBER_REFERENCE' ELSE N'' END,
            CASE
                WHEN m.email_address = N''
                  OR m.email_address NOT LIKE N'%_@_%._%'
                  OR m.email_address LIKE N'% %'
                  OR m.email_address LIKE N'%@%@%'
                THEN N' | INVALID_EMAIL_ADDRESS' ELSE N'' END,
            CASE WHEN m.membership_status NOT IN (N'0', N'1') THEN N' | INVALID_MEMBERSHIP_STATUS' ELSE N'' END,
            CASE WHEN m.title_code = N'' OR m.title_code LIKE N'%[^0-9]%' THEN N' | INVALID_TITLE_CODE' ELSE N'' END,
            CASE WHEN m.gender_code NOT IN (N'0', N'1', N'2', N'3', N'4') THEN N' | INVALID_GENDER_CODE' ELSE N'' END,
            CASE WHEN m.ucode <> N'' AND m.primary_programme_reference = N'' THEN N' | INVALID_UCODE' ELSE N'' END,
            CASE
                WHEN TRY_CONVERT(DATE, m.date_of_birth, 23) IS NULL
                  OR m.date_of_birth NOT LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                THEN N' | INVALID_DATE_OF_BIRTH' ELSE N'' END,
            CASE WHEN m.country_code NOT LIKE N'[A-Z][A-Z]' THEN N' | INVALID_COUNTRY_CODE_FORMAT' ELSE N'' END,
            CASE
                WHEN m.country_code NOT IN
                (
                    N'AD',N'AE',N'AF',N'AG',N'AI',N'AL',N'AM',N'AN',N'AO',N'AQ',N'AR',N'AS',N'AT',N'AU',N'AW',N'AX',
                    N'AZ',N'BA',N'BB',N'BD',N'BE',N'BF',N'BG',N'BH',N'BI',N'BJ',N'BL',N'BM',N'BN',N'BO',N'BR',N'BS',
                    N'BT',N'BV',N'BW',N'BY',N'BZ',N'CA',N'CC',N'CD',N'CF',N'CG',N'CH',N'CI',N'CK',N'CL',N'CM',N'CN',
                    N'CO',N'CR',N'CU',N'CV',N'CX',N'CY',N'CZ',N'DE',N'DJ',N'DK',N'DM',N'DO',N'DZ',N'EC',N'EE',N'EG',
                    N'EH',N'ER',N'ES',N'ET',N'FI',N'FJ',N'FK',N'FM',N'FO',N'FR',N'GA',N'GB',N'GD',N'GE',N'GF',N'GG',
                    N'GH',N'GI',N'GL',N'GM',N'GN',N'GP',N'GQ',N'GR',N'GS',N'GT',N'GU',N'GW',N'GY',N'HK',N'HM',N'HN',
                    N'HR',N'HT',N'HU',N'ID',N'IE',N'IL',N'IM',N'IN',N'IO',N'IQ',N'IR',N'IS',N'IT',N'JE',N'JM',N'JO',
                    N'JP',N'KE',N'KG',N'KH',N'KI',N'KM',N'KN',N'KP',N'KR',N'KW',N'KY',N'KZ',N'LA',N'LB',N'LC',N'LI',
                    N'LK',N'LR',N'LS',N'LT',N'LU',N'LV',N'LY',N'MA',N'MC',N'MD',N'ME',N'MF',N'MG',N'MH',N'MK',N'ML',
                    N'MM',N'MN',N'MO',N'MP',N'MQ',N'MR',N'MS',N'MT',N'MU',N'MV',N'MW',N'MX',N'MY',N'MZ',N'NA',N'NC',
                    N'NE',N'NF',N'NG',N'NI',N'NL',N'NO',N'NP',N'NR',N'NU',N'NZ',N'OM',N'PA',N'PE',N'PF',N'PG',N'PH',
                    N'PK',N'PL',N'PM',N'PN',N'PR',N'PS',N'PT',N'PW',N'PY',N'QA',N'RE',N'RO',N'RS',N'RU',N'RW',N'SA',
                    N'SB',N'SC',N'SD',N'SE',N'SG',N'SH',N'SI',N'SJ',N'SK',N'SL',N'SM',N'SN',N'SO',N'SR',N'SS',N'ST',
                    N'SV',N'SY',N'SZ',N'TC',N'TD',N'TF',N'TG',N'TH',N'TJ',N'TK',N'TL',N'TM',N'TN',N'TO',N'TR',N'TT',
                    N'TV',N'TW',N'TZ',N'UA',N'UG',N'UM',N'US',N'UY',N'UZ',N'VA',N'VC',N'VE',N'VG',N'VI',N'VN',N'VU',
                    N'WF',N'WS',N'YE',N'YT',N'ZA',N'ZM',N'ZW'
                )
                THEN N' | INVALID_COUNTRY_CODE' ELSE N'' END,
            CASE
                WHEN m.post_code NOT LIKE N'[A-Z][0-9]% [0-9][A-Z][A-Z]'
                 AND m.post_code NOT LIKE N'[A-Z][A-Z][0-9]% [0-9][A-Z][A-Z]'
                THEN N' | INVALID_POST_CODE' ELSE N'' END,
            CASE WHEN LEN(m.primary_programme_reference) > 11 THEN N' | MAX_LENGTH_PRIMARY_PROGRAMME_REFERENCE' ELSE N'' END,
            CASE WHEN LEN(m.first_name) > 100 THEN N' | MAX_LENGTH_FIRST_NAME' ELSE N'' END,
            CASE WHEN LEN(m.last_name) > 100 THEN N' | MAX_LENGTH_LAST_NAME' ELSE N'' END,
            CASE WHEN LEN(m.gender_code) > 1 THEN N' | MAX_LENGTH_GENDER_CODE' ELSE N'' END,
            CASE WHEN LEN(m.address_line_1) > 100 THEN N' | MAX_LENGTH_ADDRESS_LINE_1' ELSE N'' END,
            CASE WHEN LEN(m.address_line_2) > 100 THEN N' | MAX_LENGTH_ADDRESS_LINE_2' ELSE N'' END,
            CASE WHEN LEN(m.town_city) > 50 THEN N' | MAX_LENGTH_TOWN_CITY' ELSE N'' END,
            CASE WHEN LEN(m.state_region) > 50 THEN N' | MAX_LENGTH_STATE_REGION' ELSE N'' END,
            CASE WHEN LEN(m.post_code) > 50 THEN N' | MAX_LENGTH_POST_CODE' ELSE N'' END,
            CASE WHEN LEN(m.email_address) > 100 THEN N' | MAX_LENGTH_EMAIL_ADDRESS' ELSE N'' END,
            CASE
                WHEN m.main_phone <> N''
                 AND (
                    LEN(m.main_phone) NOT BETWEEN 8 AND 16
                    OR LEFT(m.main_phone, 1) <> N'+'
                    OR SUBSTRING(m.main_phone, 2, 1) LIKE N'[^1-9]'
                    OR SUBSTRING(m.main_phone, 2, LEN(m.main_phone)) LIKE N'%[^0-9]%'
                 )
                THEN N' | INVALID_MAIN_PHONE' ELSE N'' END,
            CASE
                WHEN m.business_phone <> N''
                 AND (
                    LEN(m.business_phone) NOT BETWEEN 8 AND 16
                    OR LEFT(m.business_phone, 1) <> N'+'
                    OR SUBSTRING(m.business_phone, 2, 1) LIKE N'[^1-9]'
                    OR SUBSTRING(m.business_phone, 2, LEN(m.business_phone)) LIKE N'%[^0-9]%'
                 )
                THEN N' | INVALID_BUSINESS_PHONE' ELSE N'' END,
            CASE
                WHEN m.home_phone <> N''
                 AND (
                    LEN(m.home_phone) NOT BETWEEN 8 AND 16
                    OR LEFT(m.home_phone, 1) <> N'+'
                    OR SUBSTRING(m.home_phone, 2, 1) LIKE N'[^1-9]'
                    OR SUBSTRING(m.home_phone, 2, LEN(m.home_phone)) LIKE N'%[^0-9]%'
                 )
                THEN N' | INVALID_HOME_PHONE' ELSE N'' END
        ))) AS validation_reason_codes
    INTO #rejected
    FROM #mapped m;

    -- Step 8: Remove the leading separator from concatenated validation reason codes.
    UPDATE #rejected
    SET validation_reason_codes = CASE
        WHEN LEFT(validation_reason_codes, 2) = N'| ' THEN SUBSTRING(validation_reason_codes, 3, LEN(validation_reason_codes))
        ELSE validation_reason_codes
    END;

    -- Step 9: Keep only rows that produced one or more validation failures.
    DELETE FROM #rejected
    WHERE validation_reason_codes = N'';

    -- Step 10: Split rows with no validation failures into the valid working set.
    SELECT m.*
    INTO #valid
    FROM #mapped m
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM #rejected r
        WHERE r.datafeed_id = m.datafeed_id
    );

    -- Step 11: Reject rows whose email is reused by another input row in the same scheme.
    INSERT INTO #rejected
    SELECT
        v.*,
        N'EMAIL_CONFLICT_INPUT_MEMBERS'
    FROM #valid v
    WHERE EXISTS
    (
        SELECT 1
        FROM #valid x
        WHERE x.email_address = v.email_address
          AND x.scheme_id = v.scheme_id
          AND x.primary_member_reference <> v.primary_member_reference
    );

    -- Step 12: Remove input email-conflict rejects from the valid working set.
    DELETE v
    FROM #valid v
    WHERE EXISTS
    (
        SELECT 1
        FROM #rejected r
        WHERE r.datafeed_id = v.datafeed_id
          AND r.validation_reason_codes = N'EMAIL_CONFLICT_INPUT_MEMBERS'
    );

    -- Step 13: Reject rows whose email is already owned by a different existing tempmember in the same scheme.
    INSERT INTO #rejected
    SELECT
        v.*,
        N'EMAIL_CONFLICT_EXISTING_MEMBER'
    FROM #valid v
    WHERE EXISTS
    (
        SELECT 1
        FROM HSBC_ETL.tempmembers tm
        WHERE LOWER(LTRIM(RTRIM(ISNULL(tm.PrimaryEmail, N'')))) = v.email_address
          AND tm.SchemeID = v.scheme_id
          AND UPPER(LTRIM(RTRIM(ISNULL(tm.Reference1, N'')))) <> v.primary_member_reference
    );

    -- Step 14: Remove existing-member email-conflict rejects from the valid working set.
    DELETE v
    FROM #valid v
    WHERE EXISTS
    (
        SELECT 1
        FROM #rejected r
        WHERE r.datafeed_id = v.datafeed_id
          AND r.validation_reason_codes = N'EMAIL_CONFLICT_EXISTING_MEMBER'
    );

    -- Step 15: Persist the final data quality outcome on the raw feed rows.
    UPDATE d
    SET dq_passed = CASE WHEN v.datafeed_id IS NULL THEN 0 ELSE 1 END
    FROM HSBC_ETL.rawdatafeed d
    LEFT JOIN #valid v
        ON v.datafeed_id = d.id;

    -- Step 16: Persist all rejected rows and their reason codes for audit and correction.
    INSERT INTO HSBC_ETL.datafeederrors
    (
        datafeed_id,
        processid,
        validation_reason_codes,
        validation_errors,
        conflict_existing_references,
        CIN,
        segment,
        scheme_name,
        membership_status,
        title_code,
        first_name,
        last_name,
        gender_code,
        language_code,
        date_of_birth,
        address_line_1,
        address_line_2,
        town_city,
        state_region,
        post_code,
        country_code,
        email_address,
        main_phone,
        business_phone,
        home_phone
    )
    SELECT
        r.datafeed_id,
        @ProcessId,
        r.validation_reason_codes,
        r.validation_reason_codes,
        NULL,
        r.CIN,
        r.segment,
        r.raw_scheme_name,
        r.raw_membership_status,
        r.raw_title_code,
        r.raw_first_name,
        r.raw_last_name,
        r.raw_gender_code,
        r.raw_language_code,
        r.raw_date_of_birth,
        r.raw_address_line_1,
        r.raw_address_line_2,
        r.raw_town_city,
        r.raw_state_region,
        r.raw_post_code,
        r.raw_country_code,
        r.raw_email_address,
        r.raw_main_phone,
        r.raw_business_phone,
        r.raw_home_phone
    FROM #rejected r;

    -- Step 17: Project valid feed rows into the HSBC_ETL.tempmembers column model.
    SELECT
        v.scheme_id AS SchemeID,
        COALESCE(tm.DateJoined, GETDATE()) AS DateJoined,
        v.primary_member_reference AS Reference1,
        v.secondary_member_reference AS Reference2,
        v.primary_programme_reference AS Reference3,
        TRY_CAST(v.membership_status AS INT) AS MembershipStatusID,
        TRY_CAST(v.title_code AS INT) AS TitleID,
        LEFT(v.first_name, 50) AS FirstName,
        v.middle_name AS MiddleName,
        LEFT(v.last_name, 50) AS Surname,
        LEFT(v.gender_code, 1) AS Sex,
        v.language_code AS LanguageID,
        TRY_CONVERT(DATETIME, v.date_of_birth, 23) AS DOB,
        v.town_city AS GeoCity,
        v.post_code AS GeoPostcode,
        v.country_code AS CountryID,
        v.main_phone AS PrimaryMobile,
        v.email_address AS PrimaryEmail
    INTO #members_model
    FROM #valid v
    OUTER APPLY
    (
        SELECT TOP (1) tm.DateJoined
        FROM HSBC_ETL.tempmembers tm
        WHERE tm.SchemeID = v.scheme_id
          AND UPPER(LTRIM(RTRIM(ISNULL(tm.Reference1, N'')))) = v.primary_member_reference
        ORDER BY tm.MemberID
    ) tm;

    -- Step 18: De-duplicate valid rows by target member key before comparing to existing rows.
    ;WITH ranked AS
    (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY SchemeID, Reference1 ORDER BY Reference1) AS row_number
        FROM #members_model
    )
    DELETE FROM ranked
    WHERE row_number > 1;

    -- Step 19: Identify rows that are new or have changed values in HSBC_ETL.tempmembers.
    SELECT mm.*
    INTO #changed_members
    FROM #members_model mm
    LEFT JOIN HSBC_ETL.tempmembers tm
        ON tm.SchemeID = mm.SchemeID
       AND UPPER(LTRIM(RTRIM(ISNULL(tm.Reference1, N'')))) = mm.Reference1
    WHERE tm.MemberID IS NULL
       OR ISNULL(CONVERT(NVARCHAR(50), tm.DateJoined, 121), N'') <> ISNULL(CONVERT(NVARCHAR(50), mm.DateJoined, 121), N'')
       OR ISNULL(tm.Reference2, N'') <> ISNULL(mm.Reference2, N'')
       OR ISNULL(tm.Reference3, N'') <> ISNULL(mm.Reference3, N'')
       OR ISNULL(tm.MembershipStatusID, -2147483648) <> ISNULL(mm.MembershipStatusID, -2147483648)
       OR ISNULL(tm.TitleID, -2147483648) <> ISNULL(mm.TitleID, -2147483648)
       OR ISNULL(tm.FirstName, N'') <> ISNULL(mm.FirstName, N'')
       OR ISNULL(tm.MiddleName, N'') <> ISNULL(mm.MiddleName, N'')
       OR ISNULL(tm.Surname, N'') <> ISNULL(mm.Surname, N'')
       OR ISNULL(tm.Sex, N'') <> ISNULL(mm.Sex, N'')
       OR ISNULL(tm.LanguageID, N'') <> ISNULL(mm.LanguageID, N'')
       OR ISNULL(CONVERT(NVARCHAR(50), tm.DOB, 121), N'') <> ISNULL(CONVERT(NVARCHAR(50), mm.DOB, 121), N'')
       OR ISNULL(tm.GeoCity, N'') <> ISNULL(mm.GeoCity, N'')
       OR ISNULL(tm.GeoPostcode, N'') <> ISNULL(mm.GeoPostcode, N'')
       OR ISNULL(tm.CountryID, N'') <> ISNULL(mm.CountryID, N'')
       OR ISNULL(tm.PrimaryMobile, N'') <> ISNULL(mm.PrimaryMobile, N'')
       OR ISNULL(tm.PrimaryEmail, N'') <> ISNULL(mm.PrimaryEmail, N'');

    -- Step 20: Replace changed target rows transactionally.
    BEGIN TRANSACTION;

    -- Step 21: Delete current target rows for keys that will be reloaded.
    DELETE target_rows
    FROM HSBC_ETL.tempmembers target_rows
    INNER JOIN #changed_members staged_rows
        ON target_rows.SchemeID = staged_rows.SchemeID
       AND UPPER(LTRIM(RTRIM(ISNULL(target_rows.Reference1, N'')))) = staged_rows.Reference1;

    -- Step 22: Insert the new version of every changed member row.
    INSERT INTO HSBC_ETL.tempmembers
    (
        SchemeID,
        DateJoined,
        Reference1,
        Reference2,
        Reference3,
        MembershipStatusID,
        TitleID,
        FirstName,
        MiddleName,
        Surname,
        Sex,
        LanguageID,
        DOB,
        GeoCity,
        GeoPostcode,
        CountryID,
        PrimaryMobile,
        PrimaryEmail,
        DateCreated,
        DateUpdated
    )
    SELECT
        SchemeID,
        DateJoined,
        Reference1,
        Reference2,
        Reference3,
        MembershipStatusID,
        TitleID,
        FirstName,
        MiddleName,
        Surname,
        Sex,
        LanguageID,
        DOB,
        GeoCity,
        GeoPostcode,
        CountryID,
        PrimaryMobile,
        PrimaryEmail,
        GETDATE(),
        GETDATE()
    FROM #changed_members;

    COMMIT TRANSACTION;

    -- Step 23: Return run counts for input, valid, rejected, and loaded rows.
    SELECT
        @ProcessId AS processid,
        (SELECT COUNT(*) FROM #mapped) AS input_rows,
        (SELECT COUNT(*) FROM #valid) AS valid_rows,
        (SELECT COUNT(*) FROM #rejected) AS rejected_rows,
        (SELECT COUNT(*) FROM #changed_members) AS loaded_rows;
END;
GO
