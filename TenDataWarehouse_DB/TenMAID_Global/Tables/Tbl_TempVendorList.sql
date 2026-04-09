CREATE TABLE [TenMAID_Global].[Tbl_TempVendorList] (
    [Address]             NVARCHAR (200)  NULL,
    [BookingRefNo]        NVARCHAR (200)  NULL,
    [Commissioned]        BIT             NULL,
    [CountryId]           INT             NULL,
    [CreatedBy]           INT             NULL,
    [CreatedDate]         DATE            NULL,
    [CreateVendorCard]    BIT             NULL,
    [DateUpdated]         DATETIME        NULL,
    [EstBookingValue]     INT             NULL,
    [EstSupRevenue]       INT             NULL,
    [GeneralContactPhone] NVARCHAR (50)   NULL,
    [Isselected]          BIT             NULL,
    [JobID]               INT             NOT NULL,
    [NoOfBooking]         INT             NULL,
    [TempJobVendorsID]    INT             NOT NULL,
    [UpdatedBy]           INT             NULL,
    [Urgent]              BIT             NULL,
    [VendorName]          NVARCHAR (200)  NOT NULL,
    [WebSiteAddress]      NVARCHAR (1000) NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_TempVendorList] PRIMARY KEY CLUSTERED ([TempJobVendorsID] ASC)
);

