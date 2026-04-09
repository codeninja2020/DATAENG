CREATE TABLE [Genesys_dbo].[IntxAnnotation_static] (
    [Annotation] NVARCHAR (3900) NULL,
    [IndivID]    CHAR (22)       NOT NULL,
    [IntxAnnoID] INT             NOT NULL,
    [IntxID]     CHAR (22)       NOT NULL,
    [IsPrivate]  TINYINT         NOT NULL,
    [Version]    INT             NOT NULL
);

