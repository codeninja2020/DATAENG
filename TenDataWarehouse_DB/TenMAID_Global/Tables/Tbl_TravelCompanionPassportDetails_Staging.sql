CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionPassportDetails_Staging] (
    [CompanionPassportID]        INT            NOT NULL,
    [MemberID]                   INT            NULL,
    [CompanionID]                INT            NULL,
    [PassportName]               VARCHAR (100)  NULL,
    [PassportNumber]             VARCHAR (100)  NULL,
    [IssueDate]                  DATETIME       NULL,
    [Expiry]                     DATETIME       NULL,
    [PlaceofIssue]               NVARCHAR (100) NULL,
    [DOB]                        DATETIME       NULL,
    [DateCreated]                DATETIME       NULL,
    [DateUpdated]                DATETIME       NULL,
    [CreatedBy]                  INT            NULL,
    [UpdatedBy]                  INT            NULL,
    [ForeignCompanionPassportID] INT            NULL,
    [SYS_CHANGE_OPERATION]       NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]         BIGINT         NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionPassportDetails_Staging] PRIMARY KEY CLUSTERED ([CompanionPassportID] ASC)
);

