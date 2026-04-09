
CREATE PROCEDURE [dbo].[SSIS_ErrorCheck_SSISCatalog] (@outputDebug BIT = 0)
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON

/*
declare @HoursToSearch int = 24;
declare @OutputNumber int = ( CASE WHEN @HoursToSearch > 0 THEN -@HoursToSearch ELSE @HoursToSearch END );
declare @SetDateTime datetime = (select DATEADD(MINUTE,-10,DATEADD(HOUR, @OutputNumber, GETDATE())))

UPDATE dbo.SSIS_ErrorCheckTimeStamp
	SET StartDateTime = @SetDateTime;
*/
DECLARE @GetLastRunDateTime DATETIME = (
		SELECT StartDateTime
		FROM dbo.SSIS_ErrorCheckTimeStamp
		);

DECLARE @NewGetLastRunDateTime DATETIME = GETDATE();

SELECT
	EM.operation_id,
	E.Folder_Name AS SSISCatalog_FolderName,
	E.Project_name AS SSISCatalog_ProjectName,
	E.package_name AS SSISCatalog_PackageName,
	EM.Package_Name,
	CONVERT(DATETIME, O.start_time) AS Start_Time,
	ISNULL(CONVERT(DATETIME, O.end_time), '') AS End_Time,
	ISNULL(OM.message, '') AS [Error_Message],
	ISNULL(em.execution_path, '') AS Execution_Path,
	ISNULL(E.Executed_as_name, '') AS Executed_By,
	HashBytes('sha1', om.message) AS MessageHash
INTO #internalSSISDBCatalogue
FROM [SSISDB].[internal].[operations] AS O
INNER JOIN [SSISDB].[internal].[event_messages] AS EM ON EM.operation_id = O.operation_id
INNER JOIN [SSISDB].[internal].[operation_messages] AS OM ON EM.operation_id = OM.operation_id
INNER JOIN [SSISDB].[internal].[executions] AS E ON OM.Operation_id = E.EXECUTION_ID
WHERE OM.Message_Type = 120 -- 120 means Error 
	AND EM.event_name = 'OnError'
	-- This is something i'm not sure right now but SSIS.Pipeline just adding duplicates so I'm removing it. 
	AND ISNULL(EM.subcomponent_name, '') <> 'SSIS.Pipeline'
	AND CONVERT(DATETIME, O.end_time) >= @GetLastRunDateTime
	AND CONVERT(DATETIME, O.end_time) <= @NewGetLastRunDateTime

UPDATE dbo.SSIS_ErrorCheckTimeStamp
SET StartDateTime = @NewGetLastRunDateTime;

/*** Temp filtering solution ***/
--DECLARE @DateToAggregateStart DATETIME = Convert(DATETIME, DATEDIFF(DAY, 0, '27-Dec-2018'))

--DELETE
--FROM #internalSSISDBCatalogue
--WHERE SSISCatalog_ProjectName IN (
--		)
--	AND End_Time <= @DateToAggregateStart;

/*** Temp filtering solution ***/
WITH RemoveDuplicates
AS (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY operation_id,
			s.MessageHash ORDER BY Start_Time ASC
			) RowNumber,
		s.*
	FROM #internalSSISDBCatalogue s
	)
SELECT @@SERVERNAME AS ServerName,
	operation_id,
	SSISCatalog_FolderName,
	SSISCatalog_ProjectName,
	SSISCatalog_PackageName,
	Start_Time,
	End_time,
	Execution_Path,
	[Error_Message]
INTO #OutputRows
FROM RemoveDuplicates
WHERE RowNumber = 1;

DECLARE @NewLine AS CHAR(2) = CHAR(13) + CHAR(10)

SELECT DISTINCT ServerName,
	operation_id,
	SSISCatalog_FolderName,
	SSISCatalog_ProjectName,
	SSISCatalog_PackageName,
	Start_Time,
	End_time,
	STUFF((
			SELECT pmd.Execution_Path + + @NewLine + pmd.[Error_Message] + @NewLine + @NewLine
			FROM #OutputRows pmd
			WHERE our.operation_id = pmd.operation_id
			FOR XML path(''),
				TYPE
			).value('.[1]', 'nvarchar(max)'), 1, 1, '') AS ConcatErrorMessage
FROM #OutputRows our;
