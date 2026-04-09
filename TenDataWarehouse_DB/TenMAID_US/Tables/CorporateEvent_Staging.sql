CREATE TABLE [TenMAID_US].[CorporateEvent_Staging] (
    [CorporateSchemeID]    INT             NULL,
    [CreatedBy]            INT             NULL,
    [DateCreated]          DATETIME        NULL,
    [EventTypeID]          INT             NULL,
    [id]                   INT             NOT NULL,
    [Notes]                NVARCHAR (2000) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_CorporateEvent_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

