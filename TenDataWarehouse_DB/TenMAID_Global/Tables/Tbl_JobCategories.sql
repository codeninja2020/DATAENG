CREATE TABLE [TenMAID_Global].[Tbl_JobCategories] (
    [CategoryID] INT           NOT NULL,
    [CreatedOn]  SMALLDATETIME NULL,
    [IsDefault]  BIT           NULL,
    [JobID]      INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_JobCategories] PRIMARY KEY CLUSTERED ([JobID] ASC, [CategoryID] ASC)
);

