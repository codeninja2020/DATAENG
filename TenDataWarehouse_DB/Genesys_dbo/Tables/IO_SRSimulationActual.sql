CREATE TABLE [Genesys_dbo].[IO_SRSimulationActual] (
    [Abandons]                      INT            NOT NULL,
    [AvailableTimeAllocatedSeconds] NUMERIC (18)   NOT NULL,
    [CallsHandledForCallType]       INT            NOT NULL,
    [CallsHandledForStaffType]      INT            NOT NULL,
    [CallsHandledThreshold]         NUMERIC (18)   NOT NULL,
    [CallType]                      NVARCHAR (150) NOT NULL,
    [CoverageGroupID]               CHAR (22)      NULL,
    [EmailsBacklog]                 INT            NOT NULL,
    [EmailsHandled]                 INT            NOT NULL,
    [EmailsOffered]                 INT            NOT NULL,
    [HandleTimeSeconds]             NUMERIC (18)   NOT NULL,
    [IntervalStartUtc]              DATETIME       NOT NULL,
    [ModifierUserID]                NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]             DATETIME       NULL,
    [SRSimulationActualID]          CHAR (22)      NOT NULL,
    [StaffType]                     NVARCHAR (MAX) NULL,
    [TotalQueueTimeSeconds]         INT            NOT NULL,
    [Version]                       INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_SRSimulationActual] PRIMARY KEY CLUSTERED ([SRSimulationActualID] ASC)
);

