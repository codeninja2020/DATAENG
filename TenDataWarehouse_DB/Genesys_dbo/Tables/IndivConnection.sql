CREATE TABLE [Genesys_dbo].[IndivConnection] (
    [ConnInstID]       INT            NOT NULL,
    [ConnSubTypeId]    INT            NOT NULL,
    [ConnTypeID]       INT            NOT NULL,
    [IndivID]          CHAR (22)      NOT NULL,
    [IsDefault]        TINYINT        NOT NULL,
    [SystemInsertDate] DATETIME2 (7)  NULL,
    [Value]            NVARCHAR (255) NOT NULL,
    [Version]          INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IndivConnection] PRIMARY KEY CLUSTERED ([ConnInstID] ASC, [IndivID] ASC)
);

