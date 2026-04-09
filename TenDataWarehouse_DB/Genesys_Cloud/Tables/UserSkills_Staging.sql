CREATE TABLE [Genesys_Cloud].[UserSkills_Staging] (
    [id]                   BIGINT         NOT NULL,
    [userId]               NVARCHAR (MAX) NULL,
    [skillId]              NVARCHAR (MAX) NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [proficiency]          INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.UserSkills_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

