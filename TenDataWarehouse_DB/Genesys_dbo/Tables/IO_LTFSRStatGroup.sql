CREATE TABLE [Genesys_dbo].[IO_LTFSRStatGroup] (
    [CoverageGroupID]        CHAR (22)      NOT NULL,
    [LTFSRStatGroupID]       CHAR (22)      NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [PerDayStaffingReqStats] NVARCHAR (MAX) NOT NULL,
    [StaffingRequirementID]  CHAR (22)      NOT NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_LTFSRStatGroup] PRIMARY KEY CLUSTERED ([LTFSRStatGroupID] ASC)
);

