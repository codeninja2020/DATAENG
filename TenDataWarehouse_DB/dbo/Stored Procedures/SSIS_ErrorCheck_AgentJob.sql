CREATE PROCEDURE [dbo].[SSIS_ErrorCheck_AgentJob] (@outputDebug BIT = 0)
AS
--drop table [SSIS_Staging].dbo.SSISErrorCheckTimeStamp;
--create table [SSIS_Staging].dbo.SSISErrorCheckTimeStamp (
--	StartDateTime datetime not null
----	EndDateTime datetime not null
--	);
/*
declare @HoursToSearch int = 24;
declare @OutputNumber int = ( CASE WHEN @HoursToSearch > 0 THEN -@HoursToSearch ELSE @HoursToSearch END );
declare @SetDateTime datetime = (select DATEADD(MINUTE,-10,DATEADD(HOUR, @OutputNumber, GETDATE())))

update dbo.SSIS_ErrorCheckTimeStamp
	set StartDateTime = @SetDateTime;

*/
--declare @EmailAddress varchar(500) = 'ge@xten.uk; dm@xten.uk'
--declare @GetLastRunDateTime datetime = (select dateadd(hour, -48, StartDateTime) from [SSIS_Staging].dbo.SSISErrorCheckTimeStamp);
--declare @NewGetLastRunDateTime datetime = getdate();
DECLARE @GetLastRunDateTime DATETIME = (
		SELECT StartDateTime
		FROM dbo.SSIS_ErrorCheckTimeStamp
		);
DECLARE @NewGetLastRunDateTime DATETIME = getdate();--@SetDateTime  --getdate();

SELECT ServerName,
	--RowOrder,
	JobName AS AgentJobName,
	step_id,
	StepName,
	SchedulerDescription,
	run_duration,
	JobStartTime,
	AgentJobMessage,
	--AgentJobHash,
	AgentJobUser,
	ExecutionId,
	ex.folder_name AS SSISCatalog_FolderName,
	ex.project_name AS SSISCatalog_ProjectName,
	ex.package_name AS SSISCatalog_PackageName,
	ex.executed_as_name AS SSISCatalog_ExecutedAs,
	ex.object_id AS SSISObjectId
INTO #SQLAgentJob
FROM (
	SELECT @@SERVERNAME AS ServerName,
		CAST(j.name AS VARCHAR(255)) AS JobName,
		jh.step_id,
		jh.step_name AS StepName,
		CASE 
			WHEN j.description = 'No description available.'
				THEN ''
			ELSE j.description
			END AS SchedulerDescription,
		STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(jh.run_duration AS VARCHAR(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') AS run_duration,
		msdb.dbo.agent_datetime(jh.run_date, jh.run_time) AS JobStartTime,
		jh.message AS AgentJobMessage,
		--HashBytes('sha1', jh.message) as AgentJobHash,
		l.name AS AgentJobUser,
		SUBSTRING(jh.message, NULLIF(CHARINDEX('Execution ID: ', jh.message), 0) + 14, PATINDEX('%[^0-9]%', SUBSTRING(jh.message, NULLIF(CHARINDEX('Execution ID: ', jh.message), 0) + 14, 20)) - 1) ExecutionId
	FROM MSDB.DBO.SYSJOBHISTORY jh
	LEFT JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id
	LEFT JOIN Master.dbo.syslogins l ON j.owner_sid = l.sid
	WHERE run_status = 0 --failed
		AND msdb.dbo.agent_datetime(run_date, run_time) >= @GetLastRunDateTime --DATEADD(MINUTE,-10,DATEADD(HOUR, @OutputNumber, GETDATE()))
		AND msdb.dbo.agent_datetime(run_date, run_time) <= @NewGetLastRunDateTime
		--AND jh.job_id = j.job_id
		AND jh.step_name <> '(Job outcome)'
		--AND j.name NOT LIKE ('%(Staging)%')
		AND jh.message NOT LIKE ('%System.FormatException: An invalid character was found in the mail header:%')
		AND jh.message NOT LIKE ('%A .NET Framework error occurred during execution of user-defined routine or aggregate "PostRequest"%at IntuitiveSQL_TotalStay.Support.PostRequest%')
		AND jh.message NOT LIKE ('%Unable to execute job on secondary node%')
		AND jh.message NOT LIKE ('%Request to run job%refused because the job is already running from a request by User%')
	) history
LEFT JOIN SSISDB.CATALOG.EXECUTIONS ex ON ex.execution_id = history.ExecutionId --and  ex.object_id = 28

/*** Temp filtering solution ***/
--DECLARE @DateToAggregateStart DATETIME = Convert(DATETIME, DATEDIFF(DAY, 0, '27-Dec-2018'))

--DELETE
--FROM #SQLAgentJob
--WHERE AgentJobName IN (

--		)
--	AND JobStartTime <= @DateToAggregateStart;

SELECT ServerName,
	--RowOrder,
	AgentJobName,
	step_id,
	StepName,
	SchedulerDescription,
	run_duration,
	JobStartTime,
	AgentJobMessage,
	--AgentJobHash,
	AgentJobUser,
	ExecutionId,
	SSISCatalog_FolderName,
	SSISCatalog_ProjectName,
	SSISCatalog_PackageName,
	SSISCatalog_ExecutedAs,
	SSISObjectId
FROM #SQLAgentJob;
