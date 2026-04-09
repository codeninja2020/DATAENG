CREATE TABLE [TenMAID_Global].[Tbl_MemberFavouriteRestaurantsDetails_Staging] (
    [RestaurantID]         INT             NOT NULL,
    [MemberID]             INT             NULL,
    [Restaurantdetails]    NVARCHAR (1000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [ForeignRestaurantID]  INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberFavouriteRestaurantsDetails_Staging] PRIMARY KEY CLUSTERED ([RestaurantID] ASC)
);

