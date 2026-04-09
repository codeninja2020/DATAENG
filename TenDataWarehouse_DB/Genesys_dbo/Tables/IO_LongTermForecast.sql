CREATE TABLE [Genesys_dbo].[IO_LongTermForecast] (
    [Description]                 NVARCHAR (2000) NULL,
    [EndDateSUT]                  DATETIME        NOT NULL,
    [HeadcountGenerationTimeUTC]  DATETIME        NULL,
    [LongTermForecastID]          CHAR (22)       NOT NULL,
    [ModifierUserID]              NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]           DATETIME        NULL,
    [Name]                        NVARCHAR (100)  NOT NULL,
    [SchedulingUnitID]            CHAR (22)       NOT NULL,
    [SourceDataEndSUT]            DATETIME        NOT NULL,
    [SourceDataStartSUT]          DATETIME        NOT NULL,
    [SourceExcelFileName]         NVARCHAR (255)  NULL,
    [StartDateSUT]                DATETIME        NOT NULL,
    [Version]                     INT             NOT NULL,
    [VolumeDataGenerationTimeUTC] DATETIME        NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_LongTermForecast] PRIMARY KEY CLUSTERED ([LongTermForecastID] ASC)
);

