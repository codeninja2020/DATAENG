CREATE TABLE [TenMAID_Global].[Tbl_MembersTransportandToursDetails_Staging] (
    [TransportID]              INT             NOT NULL,
    [MemberID]                 INT             NULL,
    [TransportandToursdetails] NVARCHAR (2000) NULL,
    [DateCreated]              DATETIME        NULL,
    [DateUpdated]              DATETIME        NULL,
    [CreatedBy]                INT             NULL,
    [UpdatedBy]                INT             NULL,
    [ForeignTransportID]       INT             NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]       BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MembersTransportandToursDetails_Staging] PRIMARY KEY CLUSTERED ([TransportID] ASC)
);

