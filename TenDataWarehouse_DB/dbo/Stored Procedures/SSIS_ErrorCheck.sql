


--exec [dbo].[SSIS_ErrorCheck] 1;


CREATE   PROCEDURE [dbo].[SSIS_ErrorCheck] (@outputDebug BIT = 0)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON

/*
declare @HoursToSearch int = 48;
declare @OutputNumber int = ( CASE WHEN @HoursToSearch > 0 THEN -@HoursToSearch ELSE @HoursToSearch END );
declare @SetDateTime datetime = (select DATEADD(MINUTE,-10,DATEADD(HOUR, @OutputNumber, GETDATE())))

update .dbo.SSIS_ErrorCheckTimeStamp
	set StartDateTime = @SetDateTime;
*/
DECLARE @EmailAddress VARCHAR(500) = 'ge@xten.uk;Tendata@tengroup.com' --'ge@xten.uk' --'support@xdba.uk'; --'ge@xten.uk', --'support@xdba.uk'

DECLARE @GetLastRunDateTime DATETIME = (
		SELECT StartDateTime
		FROM dbo.SSIS_ErrorCheckTimeStamp
		);
DECLARE @NewGetLastRunDateTime DATETIME = getdate();--@SetDateTime  --getdate();

SELECT row_number() OVER (
		ORDER BY run_date ASC,
			run_time ASC
		) AS RowOrder,
	CAST(j.name AS VARCHAR(255)) AS JobName,
	jh.step_id,
	jh.step_name AS StepName,
	CASE 
		WHEN j.description = 'No description available.'
			THEN ''
		ELSE j.description
		END AS SchedulerDescription,
	jh.run_duration,
	msdb.dbo.agent_datetime(jh.run_date, jh.run_time) AS JobStartTime,
	jh.message
INTO #SQLAgentJob
FROM msdb.dbo.sysjobhistory jh
LEFT JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id
WHERE run_status = 0 --failed
	AND msdb.dbo.agent_datetime(run_date, run_time) >= @GetLastRunDateTime --DATEADD(MINUTE,-10,DATEADD(HOUR, @OutputNumber, GETDATE()))
	AND msdb.dbo.agent_datetime(run_date, run_time) <= @NewGetLastRunDateTime
	--AND jh.job_id = j.job_id
	AND jh.step_name <> '(Job outcome)'
	AND j.name NOT LIKE ('%(Staging)%')
	AND jh.message NOT LIKE ('%System.FormatException: An invalid character was found in the mail header:%')
	AND jh.message NOT LIKE ('%A .NET Framework error occurred during execution of user-defined routine or aggregate "PostRequest"%at IntuitiveSQL_TotalStay.Support.PostRequest%')
	AND jh.message NOT LIKE ('%Unable to execute job on secondary node%')
	AND jh.message NOT LIKE ('%Request to run job%refused because the job is already running from a request by User%')


DECLARE @xml1 NVARCHAR(max);
DECLARE @body1 NVARCHAR(max);
DECLARE @EndOfbody1 NVARCHAR(max);

IF EXISTS (
		SELECT *
		FROM #SQLAgentJob
		)
BEGIN
	SET @xml1 = cast((
				SELECT RowOrder AS 'td',
					'',
					JobName AS 'td',
					'',
					ssf.step_id AS 'td',
					'',
					ssf.StepName AS 'td',
					'',
					ssf.SchedulerDescription AS 'td',
					'',
					ssf.run_duration AS 'td',
					'',
					convert(NVARCHAR(100), ssf.JobStartTime, 121) AS 'td',
					'',
					ssf.message AS 'td',
					''
				--ssf.process_id as 'td'
				FROM #SQLAgentJob ssf
				ORDER BY RowOrder ASC
				FOR XML path('tr'),
					elements
				) AS NVARCHAR(MAX))
	--select @xml;
	SET @body1 = '
		<html>
	
		<style>
	table, th, td {
		border: 1px solid black;
		border-collapse: collapse;
		background-color: #FEFEF2;
	}
	th, td {
		padding: 5px;
		text-align: left;
	}
	</style>
	
			<body>
				<br> 
					<H3>SSIS Agent Failures: ' + @@SERVERNAME + ' between ' + convert(NVARCHAR(100), @GetLastRunDateTime) + ' and ' + convert(NVARCHAR(100), @NewGetLastRunDateTime) + '</H3>
				<br> 	
			
	<table style="width:100%">
	<tr>
	<th> RowNumber </th>
	<th> JobName </th>
	<th> step_id		 </th>
	<th> StepName	 </th>
	<th> SchedulerDescription	 </th>
	<th> run_duration	 </th>
	<th> JobStartTime	 </th>
	<th> message </th>
	</tr>'
	SET @EndofBody1 = '
	</table> 
		<br>	
		</body>
	</html>'
	SET @body1 = @body1 + isnull(@xml1, '') + @EndofBody1
END;

---------------------
CREATE TABLE #StatusLookUp (
	StatusLookUpId INT NOT NULL PRIMARY KEY,
	Description VARCHAR(255) NOT NULL UNIQUE
	)

INSERT INTO #StatusLookUp (
	StatusLookUpId,
	Description
	)
VALUES (
	1,
	'Created'
	),
	(
	2,
	'Running'
	),
	(
	3,
	'Canceled'
	),
	(
	4,
	'Failed'
	),
	(
	5,
	'Pending'
	),
	(
	6,
	'Ended Unexpectedly'
	),
	(
	7,
	'Succeeded'
	),
	(
	8,
	'Stopping'
	),
	(
	9,
	'Completed'
	);

CREATE TABLE #MessageTypes (
	message_type INT,
	message_desc VARCHAR(256)
	);

INSERT INTO #MessageTypes (
	message_type,
	message_desc
	)
VALUES (
	- 1,
	'Unknown'
	),
	(
	120,
	'Error'
	),
	(
	110,
	'Warning'
	),
	(
	70,
	'Information'
	),
	(
	10,
	'Pre-validate'
	),
	(
	20,
	'Post-validate'
	),
	(
	30,
	'Pre-execute'
	),
	(
	40,
	'Post-execute'
	),
	(
	60,
	'Progress'
	),
	(
	50,
	'StatusChange'
	),
	(
	100,
	'QueryCancel'
	),
	(
	130,
	'TaskFailed'
	),
	(
	90,
	'Diagnostic'
	),
	(
	200,
	'Custom'
	),
	(
	140,
	'DiagnosticEx Whenever an Execute Package task executes a child package, it logs this event. The event message consists of the parameter values passed to child packages.  The value of the message column for DiagnosticEx is XML text.'
	),
	(
	400,
	'NonDiagnostic'
	),
	(
	80,
	'VariableValueChanged'
	);

CREATE TABLE #Messages (
	message_source_type INT,
	message_source_desc VARCHAR(256)
	);

INSERT INTO #Messages (
	message_source_type,
	message_source_desc
	)
VALUES (
	10,
	'Entry APIs, such as T-SQL and CLR Stored procedures'
	),
	(
	20,
	'External process used to run package (ISServerExec.exe)'
	),
	(
	30,
	'Package-level objects'
	),
	(
	40,
	'Control Flow tasks'
	),
	(
	50,
	'Control Flow containers'
	),
	(
	60,
	'Data Flow task'
	);

--select * From SSISDB.catalog.packages ;
--select * from SSISDB.catalog.operations;
--select  * from SSISDB.catalog.projects ;
SELECT row_number() OVER (
		ORDER BY o.operation_id ASC,
			om.operation_message_id ASC,
			message_time ASC
		) AS RowNumber,
	f.name AS ParentFolderName,
	o.object_name AS FailingPackageName,
	SUBSTRING(om.message, 0, CHARINDEX(':', om.message)) AS FailingObjectName,
	--pak.name as FailingProjectName,
	o.object_id,
	o.caller_name,
	o.server_name,
	o.operation_id,
	convert(DATETIME, om.message_time) AS message_time,
	em.message_desc,
	--om.message_type,
	d.message_source_desc,
	om.message,
	o.process_id
--om.*
INTO #SSISFailures
FROM SSISDB.CATALOG.operation_messages AS om
INNER JOIN SSISDB.CATALOG.operations AS o ON o.operation_id = om.operation_id
INNER JOIN #MessageTypes em ON em.message_type = om.message_type
INNER JOIN #Messages d ON D.message_source_type = om.message_source_type
LEFT JOIN SSISDB.CATALOG.projects pro ON o.object_id = pro.project_id
	AND o.object_name = pro.name
LEFT JOIN SSISDB.CATALOG.folders f ON pro.folder_id = f.folder_id
WHERE om.message_type IN (
		--	70, --Information
		110, --Warning
		120, --Error
		130, --TaskFailed
		- 1 --Unkown
		)
	AND
	convert(DATETIME, start_time) >= @GetLastRunDateTime
	AND convert(DATETIME, start_time) <= @NewGetLastRunDateTime
	AND message_desc <> 'warning'
	AND f.name IN (
		'IVCtoBI-Transfer',
		'Azure_DW'
		)

--------------
DECLARE @xml NVARCHAR(max);
DECLARE @body NVARCHAR(max);
DECLARE @EndOfbody NVARCHAR(max);

IF EXISTS (
		SELECT *
		FROM #SSISFailures
		)
BEGIN
	SET @xml = cast((
				SELECT ssf.operation_id AS 'td',
					--	row_number() over (order by ssf.message_time asc , ssf.Process_Id ASC) as 'td',
					'',
					ssf.ParentFolderName AS 'td',
					'',
					ssf.FailingPackageName AS 'td',
					'',
					ssf.FailingObjectName AS 'td',
					'',
					convert(VARCHAR(100), ssf.message_time, 121) AS 'td',
					'',
					ssf.message_desc AS 'td',
					'',
					ssf.message_source_desc AS 'td',
					'',
					ssf.message AS 'td',
					''
				--ssf.process_id as 'td'
				FROM #SSISFailures ssf
				ORDER BY RowNumber ASC
				FOR XML path('tr'),
					elements
				) AS NVARCHAR(MAX))
	--select @xml;
	SET @body = '
		<html>
	
		<style>
	table, th, td {
		border: 1px solid black;
		border-collapse: collapse;
		background-color: #FEFEF2;
	}
	th, td {
		padding: 5px;
		text-align: left;
	}
	</style>
	
			<body>
				<br>
					<H3>Integration Services Catalog Failures: ' + @@SERVERNAME + ' between ' + convert(NVARCHAR(100), @GetLastRunDateTime) + ' and ' + convert(NVARCHAR(100), @NewGetLastRunDateTime) + '</H3>
				<br> 
			
	<table style="width:100%">
	<tr>
	<th> operationId </th>
	<th> ParentFolderName </th>
	<th> FailingPackageName </th>
	<th> FailingObjectName </th>
	<th> message_time </th>
	<th> message_desc </th>
	<th> message_source_desc </th>
	<th> message </th>
	</tr>'
	SET @EndofBody = '
	</table> 
		<br>	
		</body>
	</html>'
	SET @body = @body + isnull(@xml, '') + @EndofBody;
END;

/* --------- Internal Views for the SSIS Catalogue which somehow differ to the other views------------- */
SELECT EM.operation_id,
	E.Folder_Name AS Project_Name,
	E.Project_name AS SSIS_Project_Name,
	EM.Package_Name,
	CONVERT(DATETIME, O.start_time) AS Start_Time,
	isnull(CONVERT(DATETIME, O.end_time), '') AS End_Time,
	isnull(OM.message, '') AS [Error_Message],
	isnull(EM.Event_Name, '') AS Event_Name,
	isnull(EM.Message_Source_Name, '') AS Component_Name,
	isnull(EM.Subcomponent_Name, '') AS Sub_Component_Name,
	isnull(E.Environment_Name, '') AS Environment_Name,
	--CASE E.Use32BitRunTime WHEN 1 THEN 'Yes' ELSE 'NO' END Use32BitRunTime,
	isnull(EM.Package_Path, '') AS Package_Path,
	isnull(E.Executed_as_name, '') AS Executed_By
INTO #internalSSISDBCatalogue
FROM [SSISDB].[internal].[operations] AS O
INNER JOIN [SSISDB].[internal].[event_messages] AS EM ON EM.operation_id = O.operation_id
INNER JOIN [SSISDB].[internal].[operation_messages] AS OM ON EM.operation_id = OM.operation_id
INNER JOIN [SSISDB].[internal].[executions] AS E ON OM.Operation_id = E.EXECUTION_ID
WHERE OM.Message_Type = 120 -- 120 means Error 
	AND EM.event_name = 'OnError'
	-- This is something i'm not sure right now but SSIS.Pipeline just adding duplicates so I'm removing it. 
	AND ISNULL(EM.subcomponent_name, '') <> 'SSIS.Pipeline'
	AND CONVERT(DATETIME, O.start_time) >= @GetLastRunDateTime
	AND CONVERT(DATETIME, O.start_time) <= @NewGetLastRunDateTime
	AND E.Project_name NOT IN (
		'CMI Mapping',
		'TSA Adapter'
		)
ORDER BY EM.operation_id DESC

--drop table #internalSSISDBCatalogue
DECLARE @xml4 NVARCHAR(max);
DECLARE @body4 NVARCHAR(max);
DECLARE @EndOfbody4 NVARCHAR(max);

IF EXISTS (
		SELECT *
		FROM #internalSSISDBCatalogue
		)
BEGIN
	SET @xml4 = cast((
				SELECT ssf.operation_id AS 'td',
					--	row_number() over (order by ssf.message_time asc , ssf.Process_Id ASC) as 'td',
					'',
					ssf.Project_Name AS 'td',
					'',
					ssf.SSIS_Project_Name AS 'td',
					'',
					ssf.package_name AS 'td',
					'',
					convert(VARCHAR(100), ssf.Start_Time, 121) AS 'td',
					'',
					convert(VARCHAR(100), ssf.End_Time, 121) AS 'td',
					'',
					ssf.[Error_Message] AS 'td',
					'',
					ssf.event_name AS 'td',
					'',
					ssf.Component_Name AS 'td',
					'',
					ssf.Sub_Component_Name AS 'td',
					'',
					ssf.environment_name AS 'td',
					'',
					ssf.package_path AS 'td',
					'',
					ssf.Executed_By AS 'td',
					''
				FROM #internalSSISDBCatalogue ssf
				ORDER BY operation_id ASC
				FOR XML path('tr'),
					elements
				) AS NVARCHAR(MAX))
	--select @xml4;
	SET @body4 = '
		<html>
	
		<style>
	table, th, td {
		border: 1px solid black;
		border-collapse: collapse;
		background-color: #FEFEF2;
	}
	th, td {
		padding: 5px;
		text-align: left;
	}
	</style>
	
			<body>
				<br>
					<H3>Integration Services Catalog (Internal Views) Failures: ' + @@SERVERNAME + ' between ' + convert(NVARCHAR(100), @GetLastRunDateTime) + ' and ' + convert(NVARCHAR(100), @NewGetLastRunDateTime) + '</H3>
				<br> 
			
	<table style="width:100%">
	<tr>
	<th> operationId </th>
	<th> Project Name </th>
	<th> SSIS Project_Name </th>
	<th> Package Name </th>
	<th> Start Time </th>
	<th> End Time </th>
	<th> Error Message </th>
	<th> Event Name </th>
	<th> Component_Name </th>
	<th> Sub_Component_Name </th>
	<th> Environment_Name </th>
	<th> Package_Path </th>
	<th> Executed_By </th>
	</tr>'
	SET @EndOfbody4 = '
	</table> 
		<br>	
		</body>
	</html>'
	SET @body4 = @body4 + isnull(@xml4, '') + @EndOfbody4;
END;

/* Join up the XML Strings and email them */
DECLARE @Output NVARCHAR(max) = isnull(@body1, '') + isnull(@body, '') --+ isnull(@body3, '');

IF @outputDebug = 1
	SELECT @Output

/* DB Mail must be enabled */
IF @Output <> ''
BEGIN
	DECLARE @EmailSubject VARCHAR(100) = 'Job steps have failed. Check them out: ' + convert(VARCHAR(100), GETDATE());
	DECLARE @DBMailProfile VARCHAR(100);

	SET @DbMailProfile = (
			SELECT name
			FROM msdb.dbo.sysmail_profile
			)

	EXEC msdb.dbo.sp_send_dbmail @profile_name = @DbMailProfile,
		@recipients = @EmailAddress, --'ge@xten.uk', --'support@xdba.uk',
		@subject = @EmailSubject,
		@body = @Output,
		@body_format = 'HTML';
END;

--update dbo.SSIS_ErrorCheckTimeStamp
--    set StartDateTime = @NewGetLastRunDateTime;

DROP TABLE #Messages;

DROP TABLE #MessageTypes

DROP TABLE #StatusLookUp;

DROP TABLE #SSISFailures;

DROP TABLE #SQLAgentJob;
