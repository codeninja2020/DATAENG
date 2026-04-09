CREATE TABLE [TenMAID_Global].[EmployeeAddressType_Staging] (
    [Description]           NVARCHAR (200) NULL,
    [EmployeeAddressTypeID] INT            NOT NULL,
    [SYS_CHANGE_OPERATION]  NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]    BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeAddressType_Staging] PRIMARY KEY CLUSTERED ([EmployeeAddressTypeID] ASC)
);

