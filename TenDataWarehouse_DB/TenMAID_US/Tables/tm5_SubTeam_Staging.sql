CREATE TABLE [TenMAID_US].[tm5_SubTeam_Staging] (
    [CreatedBy]            INT            NULL,
    [CreatedDate]          DATETIME       NULL,
    [FinanceCode]          VARCHAR (50)   NULL,
    [SubTeamId]            INT            NOT NULL,
    [SubTeamName]          NVARCHAR (100) NULL,
    [TeamId]               INT            NULL,
    [UpdatedBy]            INT            NULL,
    [UpdatedDate]          DATETIME       NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SubTeam_Staging] PRIMARY KEY CLUSTERED ([SubTeamId] ASC)
);

