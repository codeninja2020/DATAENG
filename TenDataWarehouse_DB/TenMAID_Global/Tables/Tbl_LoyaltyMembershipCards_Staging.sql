CREATE TABLE [TenMAID_Global].[Tbl_LoyaltyMembershipCards_Staging] (
    [MembershipID]         INT             NOT NULL,
    [MemberID]             INT             NULL,
    [MemberShipNumber]     NVARCHAR (50)   NULL,
    [Details]              NVARCHAR (1000) NULL,
    [Name]                 NVARCHAR (50)   NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [Organisation]         NVARCHAR (200)  NULL,
    [Password]             NVARCHAR (510)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_tbl_LoyaltyMembershipCards_Staging] PRIMARY KEY CLUSTERED ([MembershipID] ASC)
);

