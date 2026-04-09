CREATE TABLE [Cloak].[UserStates] (
    [Name]  VARCHAR (32) NULL,
    [USID]  INT          NOT NULL,
    [Value] INT          NULL,
    CONSTRAINT [PK_Cloak_UserStates] PRIMARY KEY CLUSTERED ([USID] ASC)
);

