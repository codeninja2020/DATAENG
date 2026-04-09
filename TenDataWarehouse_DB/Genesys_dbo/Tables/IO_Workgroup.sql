CREATE TABLE [Genesys_dbo].[IO_Workgroup] (
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [SchedulingUnitID]  CHAR (22)      NOT NULL,
    [SiteID]            INT            NULL,
    [UsesSkills]        TINYINT        NOT NULL,
    [Version]           INT            NOT NULL,
    [WorkgroupID]       CHAR (22)      NOT NULL,
    [WorkgroupName]     NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Workgroup] PRIMARY KEY CLUSTERED ([WorkgroupID] ASC)
);

