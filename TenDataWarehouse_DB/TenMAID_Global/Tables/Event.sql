CREATE TABLE [TenMAID_Global].[Event] (
    [EventID]             INT             NOT NULL,
    [EventTypeID]         INT             NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [CreatedByEmployeeID] INT             NULL,
    [DateUpdated]         DATETIME SPARSE NULL,
    [UpdatedByEmployeeID] INT SPARSE      NULL,
    [USEventId]           INT             NULL,
    [Notes]               NVARCHAR (4000) NULL,
    CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED ([EventID] ASC) WITH (FILLFACTOR = 90)
);

