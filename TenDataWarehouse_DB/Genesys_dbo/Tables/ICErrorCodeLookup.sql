CREATE TABLE [Genesys_dbo].[ICErrorCodeLookup] (
    [ErrorDescription] NVARCHAR (50) NOT NULL,
    [ICErrorCode]      NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ICErrorCodeLookup] PRIMARY KEY CLUSTERED ([ICErrorCode] ASC)
);

