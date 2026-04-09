CREATE TABLE [Genesys_dbo].[IO_DayClassification] (
    [DayClassificationID]   CHAR (22)       NOT NULL,
    [DayClassificationName] NVARCHAR (100)  NOT NULL,
    [DayType]               INT             NOT NULL,
    [Description]           NVARCHAR (2000) NULL,
    [IgnoreACDData]         TINYINT         NULL,
    [IgnoreACDDataForLTF]   TINYINT         NULL,
    [ModifierUserID]        NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]     DATETIME        NULL,
    [SpecialDayType]        INT             NOT NULL,
    [Version]               INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_DayClassification] PRIMARY KEY CLUSTERED ([DayClassificationID] ASC)
);

