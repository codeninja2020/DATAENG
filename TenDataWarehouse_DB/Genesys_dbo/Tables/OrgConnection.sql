CREATE TABLE [Genesys_dbo].[OrgConnection] (
    [ConnInstId]       INT            NOT NULL,
    [ConnSubTypeId]    INT            NOT NULL,
    [ConnTypeID]       INT            NOT NULL,
    [IsDefault]        TINYINT        NOT NULL,
    [IsDefForIndiv]    TINYINT        NOT NULL,
    [IsDefForLoc]      TINYINT        NOT NULL,
    [OrgID]            CHAR (22)      NOT NULL,
    [SystemInsertDate] DATETIME2 (7)  NULL,
    [Value]            NVARCHAR (255) NOT NULL,
    [Version]          INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_OrgConnection] PRIMARY KEY CLUSTERED ([ConnInstId] ASC)
);

