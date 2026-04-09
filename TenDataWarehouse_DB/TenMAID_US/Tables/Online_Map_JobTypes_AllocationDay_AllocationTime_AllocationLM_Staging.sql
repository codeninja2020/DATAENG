CREATE TABLE [TenMAID_US].[Online_Map_JobTypes_AllocationDay_AllocationTime_AllocationLM_Staging] (
    [AllocDayId]           INT            NULL,
    [AllocTimeId]          INT            NULL,
    [Id]                   INT            NOT NULL,
    [IsEndTimeInclusive]   BIT            NULL,
    [IsStartTimeInclusive] BIT            NULL,
    [JobTypeId]            INT            NULL,
    [LMDescription]        NVARCHAR (MAX) NULL,
    [LMId]                 INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Online_Map_JobTypes_AllocationDay_AllocationTime_AllocationLM_Staging] PRIMARY KEY CLUSTERED ([Id] ASC)
);

