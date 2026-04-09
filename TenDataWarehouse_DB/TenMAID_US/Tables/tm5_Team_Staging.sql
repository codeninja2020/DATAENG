CREATE TABLE [TenMAID_US].[tm5_Team_Staging] (
    [CreatedBy]            INT            NULL,
    [CreatedDate]          DATETIME       NULL,
    [SubRegionId]          INT            NULL,
    [TeamId]               INT            NOT NULL,
    [TeamName]             NVARCHAR (100) NULL,
    [UpdatedBy]            INT            NULL,
    [UpdatedDate]          DATETIME       NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_Team_Staging] PRIMARY KEY CLUSTERED ([TeamId] ASC)
);

