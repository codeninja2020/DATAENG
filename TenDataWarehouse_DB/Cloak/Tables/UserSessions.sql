CREATE TABLE [Cloak].[UserSessions] (
    [Extension]    VARCHAR (50)  NOT NULL,
    [ID]           INT           NOT NULL,
    [IPAddress]    VARCHAR (50)  NULL,
    [LoginTime]    DATETIME      NOT NULL,
    [LogoutReason] VARCHAR (255) NOT NULL,
    [LogoutTime]   DATETIME      NULL,
    [SiteID]       INT           NULL,
    [UserID]       INT           NOT NULL,
    CONSTRAINT [PK_Cloak_UserSessions] PRIMARY KEY CLUSTERED ([ID] ASC)
);

