CREATE TABLE [TenMAID_US].[tm5_RequestSubRequestMapping] (
    [JobStatusId]      INT NULL,
    [RequestMappingId] INT NOT NULL,
    [RequestTypeId]    INT NULL,
    [SubRequestTypeId] INT NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_RequestSubRequestMapping] PRIMARY KEY CLUSTERED ([RequestMappingId] ASC)
);

