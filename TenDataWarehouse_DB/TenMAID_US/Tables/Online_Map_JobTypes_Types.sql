CREATE TABLE [TenMAID_US].[Online_Map_JobTypes_Types] (
    [Category]  VARCHAR (10) NULL,
    [Id]        INT          NOT NULL,
    [IsClosed]  BIT          NOT NULL,
    [JobTypeId] INT          NOT NULL,
    [TypeId]    INT          NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Online_Map_JobTypes_Types] PRIMARY KEY CLUSTERED ([Id] ASC)
);

