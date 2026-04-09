CREATE TABLE [TenMAID_US].[MemberContactDetails_Staging] (
    [ContactID]            INT            NOT NULL,
    [ContactMethodID]      INT            NULL,
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [Details]              NVARCHAR (500) NULL,
    [ForeignContactId]     INT            NULL,
    [MemberID]             INT            NULL,
    [PrimaryContact]       BIT            NULL,
    [UpdatedBy]            INT            NULL,
    [Value]                VARCHAR (255)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_MemberContactDetails_Staging] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

