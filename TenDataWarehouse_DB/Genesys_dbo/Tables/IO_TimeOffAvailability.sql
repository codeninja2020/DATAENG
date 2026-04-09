CREATE TABLE [Genesys_dbo].[IO_TimeOffAvailability] (
    [AvailabilityDateSUT]   DATETIME       NOT NULL,
    [AvailableMinutes]      NUMERIC (18)   NOT NULL,
    [CoverageGroupID]       CHAR (22)      NOT NULL,
    [IsBlackout]            TINYINT        NOT NULL,
    [ModifierUserID]        NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]     DATETIME       NULL,
    [TimeOffAvailabilityID] CHAR (22)      NOT NULL,
    [Version]               INT            NOT NULL,
    [WaitlistedMinutes]     NUMERIC (18)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_TimeOffAvailability] PRIMARY KEY CLUSTERED ([TimeOffAvailabilityID] ASC)
);

