CREATE TABLE [TenMAID_Global].[JobInteraction] (
    [JobInteractionID] INT            NOT NULL,
    [Name]             NVARCHAR (100) NOT NULL,
    [orderby]          INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_JobInteraction] PRIMARY KEY CLUSTERED ([JobInteractionID] ASC)
);

