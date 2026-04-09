CREATE TABLE [Genesys_dbo].[IndivAddress] (
    [AddrInstID]       INT            NOT NULL,
    [AddrTypeID]       INT            NOT NULL,
    [City]             NVARCHAR (50)  NULL,
    [Country]          NVARCHAR (50)  NULL,
    [IndivID]          CHAR (22)      NOT NULL,
    [IsDefault]        TINYINT        NOT NULL,
    [State]            NVARCHAR (20)  NULL,
    [StreetAddress]    NVARCHAR (255) NULL,
    [SystemInsertDate] DATETIME2 (7)  NULL,
    [Version]          INT            NOT NULL,
    [zip]              NVARCHAR (20)  NULL,
    CONSTRAINT [PK_Genesys_dbo_IndivAddress] PRIMARY KEY CLUSTERED ([AddrInstID] ASC)
);

