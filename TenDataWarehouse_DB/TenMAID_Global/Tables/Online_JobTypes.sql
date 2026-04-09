CREATE TABLE [TenMAID_Global].[Online_JobTypes] (
    [AddTimeSpanToDueDate] INT            NOT NULL,
    [ApplyPVT]             BIT            NOT NULL,
    [BriefMethodId]        INT            NOT NULL,
    [JobTypeDescription]   NVARCHAR (MAX) NOT NULL,
    [JobTypeId]            INT            NOT NULL,
    [TimeSpanToDueDate]    NVARCHAR (MAX) NOT NULL,
    [TrafficLightId]       INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_JobTypes] PRIMARY KEY CLUSTERED ([JobTypeId] ASC)
);

