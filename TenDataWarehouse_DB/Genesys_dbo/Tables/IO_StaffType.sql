CREATE TABLE [Genesys_dbo].[IO_StaffType] (
    [IsActive]          TINYINT        NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [SchedulingUnitID]  CHAR (22)      NOT NULL,
    [StaffTypeID]       CHAR (22)      NOT NULL,
    [StaffTypeName]     NVARCHAR (100) NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_StaffType] PRIMARY KEY CLUSTERED ([StaffTypeID] ASC)
);

