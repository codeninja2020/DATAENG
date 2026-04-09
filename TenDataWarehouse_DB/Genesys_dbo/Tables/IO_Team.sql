CREATE TABLE [Genesys_dbo].[IO_Team] (
    [Description]       NVARCHAR (2000) NULL,
    [IsActive]          TINYINT         NOT NULL,
    [ModifierUserID]    NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC] DATETIME        NULL,
    [SchedulingUnitID]  CHAR (22)       NOT NULL,
    [TeamID]            CHAR (22)       NOT NULL,
    [TeamName]          NVARCHAR (100)  NOT NULL,
    [Version]           INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Team] PRIMARY KEY CLUSTERED ([TeamID] ASC)
);

