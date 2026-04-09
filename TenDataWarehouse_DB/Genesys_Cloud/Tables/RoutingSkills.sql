CREATE TABLE [Genesys_Cloud].[RoutingSkills] (
    [RowId]                   BIGINT         NOT NULL,
    [RequestedRoutingSkillId] NVARCHAR (MAX) NULL,
    [Segment_RowId]           BIGINT         NULL,
    [InsertedOn]              DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.RoutingSkills] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[RoutingSkills] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

