CREATE TABLE [TenMAID_Global].[Tbl_VendorBranchInfo] (
    [Address]         NVARCHAR (1024) NULL,
    [AddressCoverage] NVARCHAR (4000) NULL,
    [BranchID]        INT             NOT NULL,
    [BranchName]      NVARCHAR (200)  NOT NULL,
    [City]            INT             NULL,
    [Country]         INT             NULL,
    [Coverage]        NVARCHAR (4000) NULL,
    [CreatedBy]       INT             NULL,
    [DateCreated]     DATETIME        NULL,
    [DateUpdated]     DATETIME        NULL,
    [ID]              INT             NOT NULL,
    [IsActive]        BIT             NULL,
    [LangID]          NVARCHAR (5)    NOT NULL,
    [Latitude]        DECIMAL (18)    NULL,
    [Longitude]       DECIMAL (18)    NULL,
    [OpeningHours]    NVARCHAR (400)  NULL,
    [UpdatedBy]       INT             NULL,
    [VendorId]        INT             NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorBranchInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);

