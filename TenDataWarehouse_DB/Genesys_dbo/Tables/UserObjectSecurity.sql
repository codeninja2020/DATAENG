CREATE TABLE [Genesys_dbo].[UserObjectSecurity] (
    [ExtObjectID] CHAR (22)      NOT NULL,
    [IndivID]     CHAR (22)      NOT NULL,
    [ObjectID]    INT            NULL,
    [ObjectName]  NVARCHAR (255) NULL,
    [ObjectType]  INT            NOT NULL,
    [UserRight]   INT            NOT NULL
);

