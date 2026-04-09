CREATE TABLE [TenMAID_Global].[Online_Types] (
    [Type]            NVARCHAR (50) NOT NULL,
    [TypeDescription] NVARCHAR (50) NULL,
    [TypeId]          INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_Types] PRIMARY KEY CLUSTERED ([TypeId] ASC)
);

