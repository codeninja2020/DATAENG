CREATE TABLE [Genesys_dbo].[IO_AccrualPlanRate] (
    [AccrualPeriod]     INT            NOT NULL,
    [AccrualPlanID]     CHAR (22)      NOT NULL,
    [AccrualPlanRateID] CHAR (22)      NOT NULL,
    [AccrualRateHours]  NUMERIC (18)   NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [UpToDuration]      INT            NULL,
    [UpToPeriod]        INT            NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AccrualPlanRate] PRIMARY KEY CLUSTERED ([AccrualPlanRateID] ASC)
);

