CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionPassportDetails] (
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
    CONSTRAINT [PK_Tbl_TravelCompanionPassportDetails] PRIMARY KEY CLUSTERED ([CompanionPassportID] ASC)
);

