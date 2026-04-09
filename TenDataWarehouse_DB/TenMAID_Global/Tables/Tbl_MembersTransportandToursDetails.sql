CREATE TABLE [TenMAID_Global].[Tbl_MembersTransportandToursDetails] (
    [TransportID]              INT             NOT NULL,
    [MemberID]                 INT             NULL,
    [TransportandToursdetails] NVARCHAR (2000) NULL,
    [DateCreated]              DATETIME        NULL,
    [DateUpdated]              DATETIME        NULL,
    [CreatedBy]                INT             NULL,
    [UpdatedBy]                INT             NULL,
    [ForeignTransportID]       INT             NULL,
    CONSTRAINT [PK_Tbl_MembersTransportandToursDetails] PRIMARY KEY CLUSTERED ([TransportID] ASC)
);

