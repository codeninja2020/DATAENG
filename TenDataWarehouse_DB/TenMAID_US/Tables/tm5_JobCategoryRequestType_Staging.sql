CREATE TABLE [TenMAID_US].[tm5_JobCategoryRequestType_Staging] (
    [JobRequestTypeId]     INT          NOT NULL,
    [RequestName]          VARCHAR (10) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_JobCategoryRequestType_Staging] PRIMARY KEY CLUSTERED ([JobRequestTypeId] ASC)
);

