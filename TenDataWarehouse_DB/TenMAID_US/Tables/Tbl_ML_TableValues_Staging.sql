CREATE TABLE [TenMAID_US].[Tbl_ML_TableValues_Staging] (
    [AirlineID]              INT          NULL,
    [ClassID]                INT          NULL,
    [DestinationID]          INT          NULL,
    [ID]                     INT          NOT NULL,
    [MDV]                    INT          NULL,
    [MerrillPoints]          INT          NULL,
    [RewardID]               INT          NULL,
    [UniqueIdentifierNumber] INT          NULL,
    [SYS_CHANGE_OPERATION]   NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]     BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_ML_TableValues_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

