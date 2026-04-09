CREATE TABLE [Genesys_dbo].[IO_AccrualPlanActivityCode] (
    [AccrualPlanActivityCodeID] CHAR (22)      NOT NULL,
    [AccrualPlanID]             CHAR (22)      NOT NULL,
    [ActivityCodeID]            CHAR (22)      NULL,
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [Version]                   INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AccrualPlanActivityCode] PRIMARY KEY CLUSTERED ([AccrualPlanActivityCodeID] ASC)
);

