CREATE TABLE [TenMAID_Global].[tm5_JobCategorySubRequestType_Staging] (
    [JobSubRequestTypeId]  INT          NOT NULL,
    [TypeName]             VARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_JobCategorySubRequestType_Staging] PRIMARY KEY CLUSTERED ([JobSubRequestTypeId] ASC)
);

