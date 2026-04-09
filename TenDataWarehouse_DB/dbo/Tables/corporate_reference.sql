CREATE TABLE [dbo].[corporate_reference] (
    [corporate_reference_id] INT           IDENTITY (1, 1) NOT NULL,
    [reference_name]         NVARCHAR (20) NULL,
    CONSTRAINT [pk_corporate_reference] PRIMARY KEY CLUSTERED ([corporate_reference_id] ASC)
);

