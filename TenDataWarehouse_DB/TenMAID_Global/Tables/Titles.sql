CREATE TABLE [TenMAID_Global].[Titles] (
    [displayorder] INT            NULL,
    [TitleID]      INT            NOT NULL,
    [TitleName]    NVARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT [PK_TenMAID_Global_Titles] PRIMARY KEY CLUSTERED ([TitleID] ASC)
);

