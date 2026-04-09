CREATE TABLE [Genesys_dbo].[LocAddress] (
    [AddrInstID]       INT            NOT NULL,
    [AddrTypeID]       INT            NOT NULL,
    [City]             NVARCHAR (50)  NULL,
    [Country]          NVARCHAR (50)  NULL,
    [IsDefault]        TINYINT        NOT NULL,
    [IsDefForIndiv]    TINYINT        NOT NULL,
    [LocID]            CHAR (22)      NOT NULL,
    [State]            NVARCHAR (20)  NULL,
    [StreetAddress]    NVARCHAR (255) NULL,
    [SystemInsertDate] DATETIME2 (7)  NULL,
    [Version]          INT            NOT NULL,
    [Zip]              NVARCHAR (20)  NULL,
    CONSTRAINT [PK_Genesys_dbo_LocAddress] PRIMARY KEY CLUSTERED ([AddrInstID] ASC)
);

