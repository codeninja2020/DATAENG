CREATE TABLE [TenMAID_Global].[Tbl_Retail] (
    [Retailid]       INT           NOT NULL,
    [MemberID]       INT           NOT NULL,
    [PreferredBrand] VARCHAR (500) NULL,
    [NoUseStores]    VARCHAR (50)  NULL,
    [DateCreated]    DATETIME      NULL,
    [DateUpdated]    DATETIME      NULL,
    [CreatedBy]      INT           NULL,
    [UpdatedBy]      INT           NULL
);

