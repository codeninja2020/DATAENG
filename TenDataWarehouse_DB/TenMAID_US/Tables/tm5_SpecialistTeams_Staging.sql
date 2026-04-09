CREATE TABLE [TenMAID_US].[tm5_SpecialistTeams_Staging] (
    [CreatedBy]            INT           NULL,
    [CreatedDate]          DATETIME      NULL,
    [SpecialistId]         INT           NOT NULL,
    [SpecialistTeamName]   NVARCHAR (50) NULL,
    [SubTeamId]            INT           NULL,
    [UpdatedBy]            INT           NULL,
    [UpdatedDate]          DATETIME      NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SpecialistTeams_Staging] PRIMARY KEY CLUSTERED ([SpecialistId] ASC)
);

