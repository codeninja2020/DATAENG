-- =============================================
-- Author:		Iain Evans (Ekco xTEN)
-- Create date: 2023-11-21
-- Description:	Merges data from [Event_NotesColumnFiltered] into [Event]
-- =============================================
CREATE PROCEDURE [TenMAID_Global].[Merge_NotesIntoEvents]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	SELECT [EventID]
	INTO #Source
	FROM [TenMAID_Global].[Event_NotesColumnFiltered]

	CREATE TABLE #WorkerTable ([EventID] [INT])

	WHILE EXISTS (SELECT 1 FROM #Source	)
	BEGIN
		WAITFOR DELAY '00:00:01'

		BEGIN TRANSACTION

		INSERT INTO #WorkerTable ([EventID])
		SELECT TOP (10000) [EventID]
		FROM #Source

		UPDATE e
		SET e.[Notes] = n.[Notes]
		FROM [TenMAID_Global].[Event] e 
		INNER JOIN #WorkerTable w ON w.[EventID] = e.[EventID]
		INNER JOIN [TenMAID_Global].[Event_NotesColumnFiltered] n ON w.[EventID] = n.[EventID]

		DELETE S
		FROM #Source S
		INNER JOIN #Workertable W ON W.[EventID] = S.[EventID]

		TRUNCATE TABLE #WorkerTable;

		COMMIT
	END

END
