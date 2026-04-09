CREATE TABLE [TenMAID_US].[Online_Types] (
    [Type]            NVARCHAR (50) NOT NULL,
    [TypeDescription] NVARCHAR (50) NULL,
    [TypeId]          INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Online_Types] PRIMARY KEY CLUSTERED ([TypeId] ASC)
);

