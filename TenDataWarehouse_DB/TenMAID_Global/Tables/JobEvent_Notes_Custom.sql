CREATE TABLE [TenMAID_Global].[JobEvent_Notes_Custom] (
    [EventID]             INT             NOT NULL,
    [EventTypeID]         INT             NOT NULL,
    [Notes]               NVARCHAR (4000) NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [CreatedByEmployeeID] INT             NULL,
    [USEventId]           INT             NULL,
    CONSTRAINT [PK_JobEvent_Notes_Custom] PRIMARY KEY CLUSTERED ([EventID] ASC) WITH (FILLFACTOR = 90)
);

