CREATE TABLE [TenMAID_Global].[Tbl_MembertravelandBusinessdetails] (
    [BusinessID]               INT             NOT NULL,
    [MemberID]                 INT             NULL,
    [Travelandbusinessdetails] NVARCHAR (2000) NULL,
    [DateCreated]              DATETIME        NULL,
    [DateUpdated]              DATETIME        NULL,
    [CreatedBy]                INT             NULL,
    [UpdatedBy]                INT             NULL,
    CONSTRAINT [PK_Tbl_MembertravelandBusinessdetails] PRIMARY KEY CLUSTERED ([BusinessID] ASC)
);

