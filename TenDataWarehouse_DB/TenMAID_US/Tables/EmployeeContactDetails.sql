CREATE TABLE [TenMAID_US].[EmployeeContactDetails] (
    [ContactID]       INT            NOT NULL,
    [ContactMethodID] INT            NOT NULL,
    [EmployeeID]      INT            NOT NULL,
    [PrimaryContact]  BIT            NULL,
    [Value]           NVARCHAR (255) NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeContactDetails] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

