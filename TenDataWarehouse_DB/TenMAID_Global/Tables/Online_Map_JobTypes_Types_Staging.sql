CREATE TABLE [TenMAID_Global].[Online_Map_JobTypes_Types_Staging] (
    [Category]             VARCHAR (10) NULL,
    [Id]                   INT          NOT NULL,
    [IsClosed]             BIT          NULL,
    [JobTypeId]            INT          NULL,
    [TypeId]               INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_Map_JobTypes_Types_Staging] PRIMARY KEY CLUSTERED ([Id] ASC)
);

