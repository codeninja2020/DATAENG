CREATE TABLE [preference].[preference_member_product] (
    [MemberProductInteractionID] INT           NOT NULL,
    [MemberID]                   INT           NULL,
    [ProductReferenceID]         INT           NULL,
    [InteractionTypeID]          INT           NULL,
    [InteractionCount]           INT           NULL,
    [Status]                     NVARCHAR (5)  NULL,
    [inserted_on]                DATETIME      NULL,
    [processid]                  VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_MemberProductInteractionID]
    ON [preference].[preference_member_product];

