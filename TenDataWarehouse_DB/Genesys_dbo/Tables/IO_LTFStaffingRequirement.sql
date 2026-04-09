CREATE TABLE [Genesys_dbo].[IO_LTFStaffingRequirement] (
    [EndDateSUT]               DATETIME       NOT NULL,
    [LastStatUpdateTimeUTC]    DATETIME       NULL,
    [LongTermForecastID]       CHAR (22)      NOT NULL,
    [LTFStaffingRequirementID] CHAR (22)      NOT NULL,
    [ModifierUserID]           NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]        DATETIME       NULL,
    [PerDayShrinkage]          NVARCHAR (MAX) NOT NULL,
    [StartDateSUT]             DATETIME       NOT NULL,
    [Version]                  INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_LTFStaffingRequirement] PRIMARY KEY CLUSTERED ([LTFStaffingRequirementID] ASC)
);

