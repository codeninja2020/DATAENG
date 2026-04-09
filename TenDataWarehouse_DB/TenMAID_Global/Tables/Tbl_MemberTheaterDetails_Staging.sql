CREATE TABLE [TenMAID_Global].[Tbl_MemberTheaterDetails_Staging] (
    [TheaterID]            INT             NOT NULL,
    [MemberID]             INT             NULL,
    [TheaterDetails]       NVARCHAR (2000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [TheaterPreferenceID]  INT             NULL,
    [ForeignTheaterID]     INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberTheaterDetails_Staging] PRIMARY KEY CLUSTERED ([TheaterID] ASC)
);

