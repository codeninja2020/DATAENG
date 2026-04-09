CREATE TABLE [TenMAID_Global].[JobTurnaroundOptions] (
    [Description]      VARCHAR (50) NULL,
    [TurnaroundOption] SMALLINT     NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_JobTurnaroundOptions] PRIMARY KEY CLUSTERED ([TurnaroundOption] ASC)
);

