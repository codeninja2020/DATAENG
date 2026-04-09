CREATE TABLE [TenMAID_US].[EmployeeContactDetails_Staging] (
    [ContactID]            INT            NOT NULL,
    [ContactMethodID]      INT            NULL,
    [EmployeeID]           INT            NULL,
    [PrimaryContact]       BIT            NULL,
    [Value]                NVARCHAR (255) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeContactDetails_Staging] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

