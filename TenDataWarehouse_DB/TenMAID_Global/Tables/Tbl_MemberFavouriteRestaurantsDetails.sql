CREATE TABLE [TenMAID_Global].[Tbl_MemberFavouriteRestaurantsDetails] (
    [RestaurantID]        INT             NOT NULL,
    [MemberID]            INT             NULL,
    [Restaurantdetails]   NVARCHAR (1000) NULL,
    [DateCreated]         DATETIME        NULL,
    [DateUpdated]         DATETIME        NULL,
    [CreatedBy]           INT             NULL,
    [UpdatedBy]           INT             NULL,
    [ForeignRestaurantID] INT             NULL,
    CONSTRAINT [PK_Tbl_MemberFavouriteRestaurantsDetails] PRIMARY KEY CLUSTERED ([RestaurantID] ASC)
);

