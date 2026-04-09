CREATE TABLE [Genesys_dbo].[IALicenseLookup] (
    [IALicenseLookupId] SMALLINT       NOT NULL,
    [License]           NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IALicenseLookup] PRIMARY KEY CLUSTERED ([License] ASC)
);

