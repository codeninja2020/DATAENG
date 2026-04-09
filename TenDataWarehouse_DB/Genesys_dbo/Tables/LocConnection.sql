CREATE TABLE [Genesys_dbo].[LocConnection] (
    [ConnInstID]       INT            NOT NULL,
    [ConnSubTypeId]    INT            NOT NULL,
    [ConnTypeID]       INT            NOT NULL,
    [IsDefault]        TINYINT        NOT NULL,
    [IsDefForIndiv]    TINYINT        NOT NULL,
    [LocID]            CHAR (22)      NOT NULL,
    [SystemInsertDate] DATETIME2 (7)  NULL,
    [Value]            NVARCHAR (255) NOT NULL,
    [Version]          INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_LocConnection] PRIMARY KEY CLUSTERED ([ConnInstID] ASC)
);

