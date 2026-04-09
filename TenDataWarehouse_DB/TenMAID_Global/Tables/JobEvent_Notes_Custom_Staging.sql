CREATE TABLE [TenMAID_Global].[JobEvent_Notes_Custom_Staging] (
    [EventID]              INT             NOT NULL,
    [EventTypeID]          INT             NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [Notes]                NVARCHAR (4000) NOT NULL,
    [CreatedByEmployeeID]  INT             NULL,
    [USEventId]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_JobEvent_Notes_Custom_Staging] PRIMARY KEY CLUSTERED ([EventID] ASC) WITH (FILLFACTOR = 90)
);

