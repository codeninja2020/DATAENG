CREATE TABLE [Genesys_dbo].[IO_ScheduleBid] (
    [BidStartDateTimeUTC]       DATETIME       NOT NULL,
    [BidStatus]                 INT            NOT NULL,
    [BidStopDateTimeUTC]        DATETIME       NOT NULL,
    [EffectiveStartDateTimeUTC] DATETIME       NOT NULL,
    [EffectiveStopDateTimeUTC]  DATETIME       NULL,
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [NamedScheduleID]           CHAR (22)      NOT NULL,
    [ScheduleBidID]             CHAR (22)      NOT NULL,
    [ScheduleGenerationOptions] NVARCHAR (MAX) NOT NULL,
    [SchedulingUnitID]          CHAR (22)      NOT NULL,
    [Version]                   INT            NOT NULL,
    [XData]                     NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ScheduleBid] PRIMARY KEY CLUSTERED ([ScheduleBidID] ASC)
);

