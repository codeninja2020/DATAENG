CREATE TABLE [TenMAID_US].[MemberAdditionalMember_Staging] (
    [AdditionalMember]          BIT           NULL,
    [AdditionalMemberID]        INT           NOT NULL,
    [AdditionalMemberName]      NVARCHAR (50) NULL,
    [Company]                   NVARCHAR (50) NULL,
    [DateOfBirth]               DATETIME      NULL,
    [ForeignAdditionalMemberID] INT           NULL,
    [Gender]                    CHAR (1)      NULL,
    [JobTitle]                  NVARCHAR (50) NULL,
    [MemberID]                  INT           NULL,
    [Relationship]              NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]        BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_MemberAdditionalMember_Staging] PRIMARY KEY CLUSTERED ([AdditionalMemberID] ASC)
);

