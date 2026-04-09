CREATE TABLE [TenMAID_Global].[MembersAddressType_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [MemberAddressTypeID]  INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_MembersAddressType_Staging] PRIMARY KEY CLUSTERED ([MemberAddressTypeID] ASC)
);

