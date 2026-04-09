CREATE TABLE [TenMAID_US].[JobTurnaroundOptions] (
    [Description]      VARCHAR (50) NULL,
    [TurnaroundOption] SMALLINT     NOT NULL,
    CONSTRAINT [PK_TenMAID_US_JobTurnaroundOptions] PRIMARY KEY CLUSTERED ([TurnaroundOption] ASC)
);

