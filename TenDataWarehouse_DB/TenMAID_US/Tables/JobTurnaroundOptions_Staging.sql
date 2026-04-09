CREATE TABLE [TenMAID_US].[JobTurnaroundOptions_Staging] (
    [Description]          VARCHAR (50) NULL,
    [TurnaroundOption]     SMALLINT     NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_JobTurnaroundOptions_Staging] PRIMARY KEY CLUSTERED ([TurnaroundOption] ASC)
);

