CREATE TABLE [TenMAID_Global].[Online_JobTypes_Staging] (
    [AddTimeSpanToDueDate] INT            NULL,
    [ApplyPVT]             BIT            NULL,
    [BriefMethodId]        INT            NULL,
    [JobTypeDescription]   NVARCHAR (MAX) NULL,
    [JobTypeId]            INT            NOT NULL,
    [TimeSpanToDueDate]    NVARCHAR (MAX) NULL,
    [TrafficLightId]       INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_JobTypes_Staging] PRIMARY KEY CLUSTERED ([JobTypeId] ASC)
);

