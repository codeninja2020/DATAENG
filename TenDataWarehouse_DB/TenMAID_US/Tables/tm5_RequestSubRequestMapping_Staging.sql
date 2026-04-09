CREATE TABLE [TenMAID_US].[tm5_RequestSubRequestMapping_Staging] (
    [JobStatusId]          INT          NULL,
    [RequestMappingId]     INT          NOT NULL,
    [RequestTypeId]        INT          NULL,
    [SubRequestTypeId]     INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_RequestSubRequestMapping_Staging] PRIMARY KEY CLUSTERED ([RequestMappingId] ASC)
);

