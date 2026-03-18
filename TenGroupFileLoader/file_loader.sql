CREATE
OR
ALTER
PROCEDURE
dbo.usp_TenGroupFileLoader_LoadEmailForwardingLogs


@LinkedServer


NVARCHAR(128) = N
'TENMAID_GLOBAL_PROD'
AS
BEGIN
SET
NOCOUNT
ON;
SET
XACT_ABORT
ON;

DECLARE @ LoadType
CHAR(1);
DECLARE @ PrevVersion
BIGINT;
DECLARE @ CurrVersion
BIGINT;
DECLARE @ RowCount
INT;
DECLARE @ SQL
NVARCHAR(MAX);
DECLARE @ TableName
NVARCHAR(200) = N
'EmailForwardingLogs';
DECLARE @ SchemaName
NVARCHAR(50) = N
'Request_Automation';
DECLARE @ ServerId
INT = 2;

/ *1.
Read
config
from SSIS_TableConfig * /

SELECT @ LoadType = tc.LoadType,


@PrevVersion

= ISNULL(tc.ChangeTrackingVersion, 0)
FROM
dbo.SSIS_TableConfig
tc
INNER
JOIN
dbo.SSIS_ServerConfig
sc
ON
tc.ServerId = sc.ServerId
WHERE
tc.TableName =


@TableName


AND
tc.SchemaName =


@SchemaName


AND
sc.ServerId =


@ServerId

;

IF @ LoadType
IS
NULL
BEGIN
RAISERROR('No SSIS_TableConfig entry for EmailForwardingLogs (ServerId=2). Aborting.', 16, 1);
RETURN;
END;

/ * ────────────────────────────────────────────────────────────────
2.
Read
Change
Tracking
CURRENT
VERSION
from source
──────────────────────────────────────────────────────────────── * /
SET @ SQL = N
'SELECT @v = ct_ver
FROM
OPENQUERY(' + QUOTENAME(@LinkedServer) +
N
', ''SELECT CHANGE_TRACKING_CURRENT_VERSION() AS ct_ver'')';

EXEC
sp_executesql @ SQL, N
'@v BIGINT OUTPUT',


@CurrVersion


OUTPUT;

PRINT
'LoadType: ' +


@LoadType
 + '  PrevVersion: ' + CAST( @ PrevVersion


AS
VARCHAR(20))
+ '  CurrVersion: ' + CAST( @ CurrVersion
AS
VARCHAR(20));

/ * ────────────────────────────────────────────────────────────────
3
A.FULL
LOAD
──────────────────────────────────────────────────────────────── * /
IF @ LoadType = 'F'
BEGIN
PRINT
'Executing FULL LOAD...';

TRUNCATE
TABLE[TenGroupFileLoader_Request_Automation].[EmailForwardingLogs];

SET @ SQL = N
'
INSERT
INTO[TenGroupFileLoader_Request_Automation].[EmailForwardingLogs]
([Message_ID], [StartProcessingTime], [FinishProcessingTime],
 [ProcessingSuccessful], [CreatedNewRequest], [LinkedToRequestNumber],
 [LinkedToMemberID], [FromEmailAddress], [Subject],
 [MailboxAddress], [SchemeId])
SELECT
[LogId], [StartProcessingTime], [FinishProcessingTime],
[ProcessingSuccessful], [CreatedNewRequest], [LinkedToRequestNumber],
[LinkedToMemberID], [FromEmailAddress], [Subject],
[MailboxAddress], [SchemeId]
FROM
' + QUOTENAME(@LinkedServer) +
N
'.[TenGroupFileLoader].[request_automation].[EmailForwardingLogs]';

EXEC
sp_executesql @ SQL;
SET @ RowCount =


@ @ROWCOUNT

;

PRINT
'Full load complete: ' + CAST( @ RowCount
AS
VARCHAR(20)) + ' rows';
END

/ * 3
B.INCREMENTAL
LOAD
USING
CHANGE
TRACKING * /
ELSE
IF @ LoadType = 'I'
AND @ CurrVersion >


@PrevVersion


BEGIN
PRINT
'Executing INCREMENTAL LOAD...';

BEGIN
TRY
BEGIN
TRANSACTION;

-- Wipe
staging
table
TRUNCATE
TABLE[TenGroupFileLoader_Request_Automation].[EmailForwardingLogs_Staging];

/ *Apply
deletes
directly
to
target * /
SET @ SQL = N
'
DELETE
d
FROM[TenGroupFileLoader_Request_Automation].[EmailForwardingLogs]
d
WHERE
EXISTS(
    SELECT
1
FROM
OPENQUERY(' + QUOTENAME(@LinkedServer) + N',
          ''
SELECT
ct.LogId
FROM
CHANGETABLE(CHANGES[request_automation].[EmailForwardingLogs], '
            + CAST( @ PrevVersion
AS
NVARCHAR(20)) + N
') ct
WHERE
ct.SYS_CHANGE_OPERATION = ''''D'''''') src
                    WHERE src.LogId = d.[Message_ID]
                )';

            EXEC sp_executesql @SQL;
            SET @RowCount = @@ROWCOUNT;
            PRINT '  Deleted: ' + CAST(@RowCount AS VARCHAR(20));

            /* Stage inserts/updates (data columns only) */
            SET @SQL = N'
                INSERT INTO [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs_Staging]
                    ([Message_ID], [StartProcessingTime], [FinishProcessingTime],
                     [ProcessingSuccessful], [CreatedNewRequest], [LinkedToRequestNumber],
                     [LinkedToMemberID], [FromEmailAddress], [Subject],
                     [MailboxAddress], [SchemeId])
                SELECT tn.LogId, tn.StartProcessingTime, tn.FinishProcessingTime,
                       tn.ProcessingSuccessful, tn.CreatedNewRequest, tn.LinkedToRequestNumber,
                       tn.LinkedToMemberID, tn.FromEmailAddress, tn.[Subject],
                       tn.MailboxAddress, tn.SchemeId
                FROM OPENQUERY(' + QUOTENAME(@LinkedServer) + N',
                    ''SELECT ct.LogId
                      FROM CHANGETABLE(CHANGES [request_automation].[EmailForwardingLogs], '
                      + CAST(@PrevVersion AS NVARCHAR(20)) + N') ct
                      WHERE ct.SYS_CHANGE_OPERATION IN (''''I'''', ''''U'''')'') ct
                INNER JOIN ' + QUOTENAME(@LinkedServer) +
                    N'.[TenGroupFileLoader].[request_automation].[EmailForwardingLogs] tn
                    ON tn.LogId = ct.LogId';

            EXEC sp_executesql @SQL;
            SET @RowCount = @@ROWCOUNT;
            PRINT '  Staged inserts/updates: ' + CAST(@RowCount AS VARCHAR(20));

            /* Delete existing rows for inserts/updates (to allow clean re-insert) */
            DELETE d
            FROM [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs] d
            INNER JOIN [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs_Staging] s
                ON s.[Message_ID] = d.[Message_ID];

            /* Insert staged new/changed rows */
            INSERT INTO [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs]
                ([Message_ID], [StartProcessingTime], [FinishProcessingTime],
                 [ProcessingSuccessful], [CreatedNewRequest], [LinkedToRequestNumber],
                 [LinkedToMemberID], [FromEmailAddress], [Subject],
                 [MailboxAddress], [SchemeId])
            SELECT
                 [Message_ID], [StartProcessingTime], [FinishProcessingTime],
                 [ProcessingSuccessful], [CreatedNewRequest], [LinkedToRequestNumber],
                 [LinkedToMemberID], [FromEmailAddress], [Subject],
                 [MailboxAddress], [SchemeId]
            FROM [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs_Staging];

            SET @RowCount = @@ROWCOUNT;
            PRINT '  Inserted/Updated: ' + CAST(@RowCount AS VARCHAR(20));

            COMMIT TRANSACTION;
            PRINT 'Incremental load complete.';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            DECLARE @ErrMsg  NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrSev  INT            = ERROR_SEVERITY();
            DECLARE @ErrStat INT            = ERROR_STATE();
            RAISERROR('Incremental load failed and was rolled back. Error: %s', @ErrSev, @ErrStat, @ErrMsg);
            RETURN;
        END CATCH;
    END
    ELSE IF @LoadType = 'I' AND @CurrVersion < @PrevVersion
    BEGIN
        RAISERROR('Change Tracking version on source (%I64d) is older than stored version (%I64d). CT may have been reset. Manual review required.', 16, 1, @CurrVersion, @PrevVersion);
        RETURN;
    END
    ELSE
    BEGIN
        PRINT 'No changes detected (version unchanged at ' + CAST(@CurrVersion AS VARCHAR(20)) + '). Skipping.';
    END;

    /*
       4. Update ChangeTrackingVersion in config table */
    UPDATE tc
    SET ChangeTrackingVersion = @CurrVersion
    FROM dbo.SSIS_TableConfig tc
    WHERE tc.TableName  = @TableName
      AND tc.SchemaName = @SchemaName
      AND tc.ServerId   = @ServerId;

    PRINT 'Done. CT version updated to ' + CAST(@CurrVersion AS VARCHAR(20));
END;
GO