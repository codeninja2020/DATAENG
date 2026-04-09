CREATE TABLE [TenMAID_Global].[Online_Map_JobTypes_AllocationDay_AllocationTime_AllocationLM] (
    [AllocDayId]           INT            NOT NULL,
    [AllocTimeId]          INT            NOT NULL,
    [Id]                   INT            NOT NULL,
    [IsEndTimeInclusive]   BIT            NOT NULL,
    [IsStartTimeInclusive] BIT            NOT NULL,
    [JobTypeId]            INT            NOT NULL,
    [LMDescription]        NVARCHAR (MAX) NULL,
    [LMId]                 INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_Map_JobTypes_AllocationDay_AllocationTime_AllocationLM] PRIMARY KEY CLUSTERED ([Id] ASC)
);

