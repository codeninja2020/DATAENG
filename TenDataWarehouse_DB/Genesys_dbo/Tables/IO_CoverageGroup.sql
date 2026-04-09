CREATE TABLE [Genesys_dbo].[IO_CoverageGroup] (
    [CoverageGroupID]   CHAR (22)      NOT NULL,
    [CoverageGroupName] NVARCHAR (100) NOT NULL,
    [IsActive]          TINYINT        NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [StaffTypeID]       CHAR (22)      NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_CoverageGroup] PRIMARY KEY CLUSTERED ([CoverageGroupID] ASC)
);

