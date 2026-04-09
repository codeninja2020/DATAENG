CREATE TABLE [TenMAID_US].[MemberContactDetails] (
    [ContactID]        INT            NOT NULL,
    [ContactMethodID]  INT            NOT NULL,
    [CreatedBy]        INT            NULL,
    [DateCreated]      DATETIME       NULL,
    [DateUpdated]      DATETIME       NULL,
    [Details]          NVARCHAR (500) NULL,
    [ForeignContactId] INT            NULL,
    [MemberID]         INT            NOT NULL,
    [PrimaryContact]   BIT            NULL,
    [UpdatedBy]        INT            NULL,
    [Value]            VARCHAR (255)  NULL,
    CONSTRAINT [PK_TenMAID_US_MemberContactDetails] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

