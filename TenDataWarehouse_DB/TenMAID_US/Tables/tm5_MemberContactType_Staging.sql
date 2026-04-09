CREATE TABLE [TenMAID_US].[tm5_MemberContactType_Staging] (
    [ContactId]            INT          NOT NULL,
    [ContactType]          VARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_MemberContactType_Staging] PRIMARY KEY CLUSTERED ([ContactId] ASC)
);

