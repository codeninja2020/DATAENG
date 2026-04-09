CREATE TABLE [Genesys_Cloud].[Users_Staging] (
    [id]                   NVARCHAR (128) NOT NULL,
    [name]                 NVARCHAR (MAX) NULL,
    [employeeId]           NVARCHAR (MAX) NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [emailAddress]         NVARCHAR (MAX) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.Users_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

