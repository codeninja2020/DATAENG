CREATE TABLE [TenMAID_US].[TenDate] (
    [DateKey]              INT           NOT NULL,
    [FullDateAlternateKey] DATETIME      NOT NULL,
    [DayNumberOfWeek]      TINYINT       NOT NULL,
    [EnglishDayNameOfWeek] NVARCHAR (10) NOT NULL,
    [DayNumberOfMonth]     TINYINT       NOT NULL,
    [DayNumberOfYear]      SMALLINT      NOT NULL,
    [WeekNumberOfYear]     TINYINT       NOT NULL,
    [EnglishMonthName]     NVARCHAR (10) NOT NULL,
    [MonthNumberOfYear]    TINYINT       NOT NULL,
    [CalendarQuarter]      TINYINT       NOT NULL,
    [CalendarYear]         SMALLINT      NOT NULL,
    [CalendarSemester]     TINYINT       NOT NULL,
    CONSTRAINT [PK_TENMAID_US_TenDate] PRIMARY KEY CLUSTERED ([DateKey] ASC),
    CONSTRAINT [AK_DimDate_FullDateAlternateKey] UNIQUE NONCLUSTERED ([FullDateAlternateKey] ASC)
);

