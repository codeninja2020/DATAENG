CREATE TABLE [TenMAID_Global].[JobTurnaroundOptions_Staging] (
    [Description]          VARCHAR (50) NULL,
    [TurnaroundOption]     SMALLINT     NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_JobTurnaroundOptions_Staging] PRIMARY KEY CLUSTERED ([TurnaroundOption] ASC)
);

