CREATE TABLE [Genesys_Cloud].[Users] (
    [id]           NVARCHAR (128) NOT NULL,
    [name]         NVARCHAR (MAX) NULL,
    [employeeId]   NVARCHAR (MAX) NULL,
    [InsertedOn]   DATETIME       NOT NULL,
    [emailAddress] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Genesys_Cloud.Users] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Users] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

