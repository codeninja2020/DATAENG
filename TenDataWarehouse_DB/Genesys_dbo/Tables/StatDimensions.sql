CREATE TABLE [Genesys_dbo].[StatDimensions] (
    [cDimension1]      NVARCHAR (50) NOT NULL,
    [cDimension2]      NVARCHAR (50) NOT NULL,
    [cDimension3]      NVARCHAR (50) NOT NULL,
    [cDimension4]      NVARCHAR (50) NOT NULL,
    [cType]            CHAR (1)      NOT NULL,
    [DimensionSet]     INT           NOT NULL,
    [SummDimensionSet] INT           NULL,
    CONSTRAINT [PK_Genesys_dbo_StatDimensions] PRIMARY KEY CLUSTERED ([DimensionSet] ASC)
);

