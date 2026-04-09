CREATE TABLE [Genesys_Cloud].[UserSkills] (
    [id]          BIGINT         NOT NULL,
    [userId]      NVARCHAR (MAX) NULL,
    [skillId]     NVARCHAR (MAX) NULL,
    [InsertedOn]  DATETIME       NOT NULL,
    [proficiency] INT            NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.UserSkills] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[UserSkills] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

