CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitCommunicationMethod_Staging] (
    [CommunicationtMethodID] INT            NOT NULL,
    [DateCreated]            DATETIME       NULL,
    [DateUpdated]            DATETIME       NULL,
    [Title]                  NVARCHAR (200) NULL,
    [SYS_CHANGE_OPERATION]   NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]     BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitCommunicationMethod_Staging] PRIMARY KEY CLUSTERED ([CommunicationtMethodID] ASC)
);

