CREATE TABLE [TenMAID_US].[Tbl_VendorBranchInfo_Staging] (
    [Address]              NVARCHAR (1024) NULL,
    [AddressCoverage]      NVARCHAR (4000) NULL,
    [BranchID]             INT             NULL,
    [BranchName]           NVARCHAR (200)  NULL,
    [City]                 INT             NULL,
    [Country]              INT             NULL,
    [Coverage]             NVARCHAR (4000) NULL,
    [CreatedBy]            INT             NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [ID]                   INT             NOT NULL,
    [IsActive]             BIT             NULL,
    [LangID]               NVARCHAR (5)    NULL,
    [Latitude]             DECIMAL (18)    NULL,
    [Longitude]            DECIMAL (18)    NULL,
    [OpeningHours]         NVARCHAR (400)  NULL,
    [UpdatedBy]            INT             NULL,
    [VendorId]             INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorBranchInfo_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

