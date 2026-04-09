CREATE TABLE [Genesys_dbo].[IO_LTFData] (
    [ForecastData]       NVARCHAR (MAX) NULL,
    [LongTermForecastID] CHAR (22)      NOT NULL,
    [LTFDataID]          CHAR (22)      NOT NULL,
    [ModifierUserID]     NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]  DATETIME       NULL,
    [RepresentativeWeek] NVARCHAR (MAX) NULL,
    [SourceData]         NVARCHAR (MAX) NULL,
    [Version]            INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_LTFData] PRIMARY KEY CLUSTERED ([LTFDataID] ASC)
);

