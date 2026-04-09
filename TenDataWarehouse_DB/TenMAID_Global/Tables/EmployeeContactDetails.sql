CREATE TABLE [TenMAID_Global].[EmployeeContactDetails] (
    [ContactID]       INT            NOT NULL,
    [ContactMethodID] INT            NOT NULL,
    [EmployeeID]      INT            NOT NULL,
    [PrimaryContact]  BIT            NULL,
    [Value]           NVARCHAR (255) NULL,
    [Details]         NVARCHAR (500) NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeContactDetails] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

