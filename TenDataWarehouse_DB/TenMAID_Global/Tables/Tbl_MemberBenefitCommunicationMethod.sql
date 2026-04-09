CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitCommunicationMethod] (
    [CommunicationtMethodID] INT            NOT NULL,
    [DateCreated]            DATETIME       NULL,
    [DateUpdated]            DATETIME       NULL,
    [Title]                  NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitCommunicationMethod] PRIMARY KEY CLUSTERED ([CommunicationtMethodID] ASC)
);

