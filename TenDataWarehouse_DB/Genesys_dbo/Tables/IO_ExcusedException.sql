CREATE TABLE [Genesys_dbo].[IO_ExcusedException] (
    [AgentID]            CHAR (22)       NOT NULL,
    [Description]        NVARCHAR (2000) NULL,
    [DurationSecs]       INT             NOT NULL,
    [ExceptionStartUTC]  DATETIME        NOT NULL,
    [ExcusedExceptionID] CHAR (22)       NOT NULL,
    [ModifierUserID]     NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]  DATETIME        NULL,
    [NamedScheduleID]    CHAR (22)       NOT NULL,
    [Version]            INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ExcusedException] PRIMARY KEY CLUSTERED ([ExcusedExceptionID] ASC)
);

