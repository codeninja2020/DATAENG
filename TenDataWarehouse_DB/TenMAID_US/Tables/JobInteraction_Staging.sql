CREATE TABLE [TenMAID_US].[JobInteraction_Staging] (
    [JobInteractionID]     INT            NOT NULL,
    [Name]                 NVARCHAR (100) NULL,
    [orderby]              INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_JobInteraction_Staging] PRIMARY KEY CLUSTERED ([JobInteractionID] ASC)
);

