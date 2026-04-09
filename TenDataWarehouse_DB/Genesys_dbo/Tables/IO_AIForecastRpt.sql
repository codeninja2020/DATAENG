CREATE TABLE [Genesys_dbo].[IO_AIForecastRpt] (
    [AIForecastRptID]   CHAR (22)       NOT NULL,
    [DataAnomalies]     NVARCHAR (2000) NOT NULL,
    [Metadata]          NVARCHAR (2000) NOT NULL,
    [Metric]            NVARCHAR (128)  NOT NULL,
    [ModifierUserID]    NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC] DATETIME        NULL,
    [RouteGroup]        NVARCHAR (1000) NOT NULL,
    [Version]           INT             NOT NULL,
    [VolumeForecastID]  CHAR (22)       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AIForecastRpt] PRIMARY KEY CLUSTERED ([AIForecastRptID] ASC)
);

