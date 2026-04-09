CREATE TABLE [TenMAID_US].[Online_Types_Staging] (
    [Type]                 NVARCHAR (50) NULL,
    [TypeDescription]      NVARCHAR (50) NULL,
    [TypeId]               INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Online_Types_Staging] PRIMARY KEY CLUSTERED ([TypeId] ASC)
);

