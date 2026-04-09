CREATE TABLE [TenMAID_Global].[Tbl_MemberAlertDetails_Staging] (
    [AlertContent]         NVARCHAR (4000) NULL,
    [AlertID]              INT             NOT NULL,
    [AlertTypeID]          INT             NULL,
    [CreatedBy]            INT             NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [Display]              NVARCHAR (50)   NULL,
    [Email]                NVARCHAR (MAX)  NULL,
    [EndDate]              DATETIME        NULL,
    [ForeignAlertID]       INT             NULL,
    [IsMemberUpload]       BIT             NULL,
    [JobAlertEmpID]        NVARCHAR (MAX)  NULL,
    [Location]             NVARCHAR (100)  NULL,
    [MemberID]             INT             NULL,
    [Priority]             INT             NULL,
    [StartDate]            DATETIME        NULL,
    [Timezone]             NVARCHAR (30)   NULL,
    [UpdatedBy]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberAlertDetails_Staging] PRIMARY KEY CLUSTERED ([AlertID] ASC)
);

