CREATE TABLE [TenMAID_US].[tm5_SubTeam] (
    [CreatedBy]   INT            NULL,
    [CreatedDate] DATETIME       NULL,
    [FinanceCode] VARCHAR (50)   NULL,
    [SubTeamId]   INT            NOT NULL,
    [SubTeamName] NVARCHAR (100) NULL,
    [TeamId]      INT            NULL,
    [UpdatedBy]   INT            NULL,
    [UpdatedDate] DATETIME       NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SubTeam] PRIMARY KEY CLUSTERED ([SubTeamId] ASC)
);

