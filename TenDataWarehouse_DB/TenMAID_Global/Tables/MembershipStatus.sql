CREATE TABLE [TenMAID_Global].[MembershipStatus] (
    [MembershipStatusID] INT            NOT NULL,
    [Name]               NVARCHAR (50)  NOT NULL,
    [Description]        NVARCHAR (200) NULL,
    CONSTRAINT [PK_TENMAID_Global_MembershipStatus] PRIMARY KEY CLUSTERED ([MembershipStatusID] ASC)
);

