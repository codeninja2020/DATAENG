CREATE TABLE [Genesys_dbo].[IO_TimeOffPlan] (
    [AllotmentDistributions]   NVARCHAR (MAX)  NULL,
    [Description]              NVARCHAR (2000) NULL,
    [EndDateSUT]               DATETIME        NOT NULL,
    [IsActive]                 TINYINT         NOT NULL,
    [IsPlanActive]             TINYINT         NOT NULL,
    [LastLTFImportTimeUTC]     DATETIME        NULL,
    [LTFStaffingRequirementID] CHAR (22)       NULL,
    [ModifierUserID]           NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]        DATETIME        NULL,
    [SchedulingUnitID]         CHAR (22)       NOT NULL,
    [StartDateSUT]             DATETIME        NOT NULL,
    [TimeOffPlanID]            CHAR (22)       NOT NULL,
    [TimeOffPlanName]          NVARCHAR (100)  NOT NULL,
    [Version]                  INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_TimeOffPlan] PRIMARY KEY CLUSTERED ([TimeOffPlanID] ASC)
);

