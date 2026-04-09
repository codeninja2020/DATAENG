CREATE TABLE [TenMAID_US].[Tbl_JobCategories] (
    [CategoryID] INT           NOT NULL,
    [CreatedOn]  SMALLDATETIME NULL,
    [IsDefault]  BIT           NULL,
    [JobID]      INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_JobCategories] PRIMARY KEY CLUSTERED ([JobID] ASC, [CategoryID] ASC)
);

