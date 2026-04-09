CREATE TABLE [TenMAID_Global].[tm5_SpecialistTeams] (
    [CreatedBy]          INT           NULL,
    [CreatedDate]        DATETIME      NULL,
    [SpecialistId]       INT           NOT NULL,
    [SpecialistTeamName] NVARCHAR (50) NULL,
    [SubTeamId]          INT           NULL,
    [UpdatedBy]          INT           NULL,
    [UpdatedDate]        DATETIME      NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_SpecialistTeams] PRIMARY KEY CLUSTERED ([SpecialistId] ASC)
);

