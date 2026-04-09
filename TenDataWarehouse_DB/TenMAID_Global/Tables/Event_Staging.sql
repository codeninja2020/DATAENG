CREATE TABLE [TenMAID_Global].[Event_Staging] (
    [EventID]              INT             NOT NULL,
    [EventTypeID]          INT             NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [CreatedByEmployeeID]  INT             NULL,
    [DateUpdated]          DATETIME SPARSE NULL,
    [UpdatedByEmployeeID]  INT SPARSE      NULL,
    [USEventId]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    [Notes]                NVARCHAR (4000) NULL,
    CONSTRAINT [PK_Event_Staging] PRIMARY KEY CLUSTERED ([EventID] ASC) WITH (FILLFACTOR = 90)
);

