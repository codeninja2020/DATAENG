CREATE TABLE [TenMAID_US].[ContactMethod_Staging] (
    [ContactMethodID]      INT            NOT NULL,
    [Description]          NVARCHAR (200) NULL,
    [IsPhone]              BIT            NULL,
    [Name]                 NVARCHAR (50)  NULL,
    [orderby]              INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_ContactMethod_Staging] PRIMARY KEY CLUSTERED ([ContactMethodID] ASC)
);

