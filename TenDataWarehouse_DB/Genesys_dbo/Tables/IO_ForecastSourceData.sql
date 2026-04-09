CREATE TABLE [Genesys_dbo].[IO_ForecastSourceData] (
    [FileName]             NVARCHAR (1000) NULL,
    [ForecastDay]          INT             NOT NULL,
    [ForecastSourceDataID] CHAR (22)       NOT NULL,
    [ModifierUserID]       NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]    DATETIME        NULL,
    [SerializedSourceData] VARCHAR (MAX)   NULL,
    [SourceDateUTC]        DATETIME        NULL,
    [Version]              INT             NOT NULL,
    [VolumeForecastID]     CHAR (22)       NOT NULL,
    [Weight]               FLOAT (53)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ForecastSourceData] PRIMARY KEY CLUSTERED ([ForecastSourceDataID] ASC)
);

