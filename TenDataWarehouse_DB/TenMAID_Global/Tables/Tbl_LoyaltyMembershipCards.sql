CREATE TABLE [TenMAID_Global].[Tbl_LoyaltyMembershipCards] (
    [MembershipID]     INT             NOT NULL,
    [MemberID]         INT             NULL,
    [MemberShipNumber] NVARCHAR (50)   NULL,
    [Details]          NVARCHAR (1000) NULL,
    [Name]             NVARCHAR (50)   NULL,
    [DateCreated]      DATETIME        NULL,
    [DateUpdated]      DATETIME        NULL,
    [CreatedBy]        INT             NULL,
    [UpdatedBy]        INT             NULL,
    [Organisation]     NVARCHAR (200)  NULL,
    [Password]         NVARCHAR (510)  NULL,
    CONSTRAINT [PK_tbl_LoyaltyMembershipCards] PRIMARY KEY CLUSTERED ([MembershipID] ASC)
);

