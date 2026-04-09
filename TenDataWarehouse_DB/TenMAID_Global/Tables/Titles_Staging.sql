CREATE TABLE [TenMAID_Global].[Titles_Staging] (
    [displayorder]         INT            NULL,
    [TitleID]              INT            NOT NULL,
    [TitleName]            NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Titles_Staging] PRIMARY KEY CLUSTERED ([TitleID] ASC)
);

