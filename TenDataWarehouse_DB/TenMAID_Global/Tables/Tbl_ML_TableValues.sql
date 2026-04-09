CREATE TABLE [TenMAID_Global].[Tbl_ML_TableValues] (
    [AirlineID]              INT NULL,
    [ClassID]                INT NULL,
    [DestinationID]          INT NULL,
    [ID]                     INT NOT NULL,
    [MDV]                    INT NULL,
    [MerrillPoints]          INT NULL,
    [RewardID]               INT NULL,
    [UniqueIdentifierNumber] INT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_ML_TableValues] PRIMARY KEY CLUSTERED ([ID] ASC)
);

