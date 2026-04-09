CREATE TABLE [TenMAID_US].[Titles_Staging] (
    [displayorder]         INT           NULL,
    [TitleID]              INT           NOT NULL,
    [TitleName]            VARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Titles_Staging] PRIMARY KEY CLUSTERED ([TitleID] ASC)
);

