CREATE TABLE [Genesys_Cloud].[RoutingSkills_Staging] (
    [RowId]                   BIGINT         NOT NULL,
    [RequestedRoutingSkillId] NVARCHAR (MAX) NULL,
    [Segment_RowId]           BIGINT         NULL,
    [InsertedOn]              DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION]    NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]      BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.RoutingSkills_Staging] PRIMARY KEY CLUSTERED ([RowId] ASC)
);

