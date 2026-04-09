CREATE TABLE [TenMAID_Global].[ContactMethod] (
    [ContactMethodID] INT            NOT NULL,
    [Description]     NVARCHAR (200) NOT NULL,
    [IsPhone]         BIT            NULL,
    [Name]            NVARCHAR (50)  NULL,
    [orderby]         INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_ContactMethod] PRIMARY KEY CLUSTERED ([ContactMethodID] ASC)
);

