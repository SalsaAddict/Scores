--IF DB_ID(N'Scores') IS NOT NULL DROP DATABASE [Scores]; CREATE DATABASE [Scores]
USE [Scores]
GO

SET NOCOUNT ON
GO

IF OBJECT_ID(N'Scores', N'V') IS NOT NULL DROP VIEW [Scores]
IF OBJECT_ID(N'Score', N'U') IS NOT NULL DROP TABLE [Score]
IF OBJECT_ID(N'Heats', N'V') IS NOT NULL DROP VIEW [Heats]
IF OBJECT_ID(N'Competitors', N'V') IS NOT NULL DROP VIEW [Competitors]
IF OBJECT_ID(N'Competitor', N'U') IS NOT NULL DROP TABLE [Competitor]
IF OBJECT_ID(N'Judges', N'V') IS NOT NULL DROP VIEW [Judges]
IF OBJECT_ID(N'Judge', N'U') IS NOT NULL DROP TABLE [Judge]
IF OBJECT_ID(N'Heat', N'U') IS NOT NULL DROP TABLE [Heat]
IF OBJECT_ID(N'Criterion', N'U') IS NOT NULL DROP TABLE [Criterion]
IF OBJECT_ID(N'Round', N'U') IS NOT NULL DROP TABLE [Round]
IF OBJECT_ID(N'Division', N'U') IS NOT NULL DROP TABLE [Division]
IF OBJECT_ID(N'CompetitorType', N'U') IS NOT NULL DROP TABLE [CompetitorType]
IF OBJECT_ID(N'Event', N'U') IS NOT NULL DROP TABLE [Event]
IF OBJECT_ID(N'User', N'U') IS NOT NULL DROP TABLE [User]
GO

CREATE TABLE [User] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[Email] NVARCHAR(255) NOT NULL,
	[Password] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_User_Email] UNIQUE ([Email])
)
GO

SET IDENTITY_INSERT [User] ON
INSERT INTO [User] ([Id], [Email], [Password])
OUTPUT [inserted].*
VALUES (0, N'pierre.henry@salsaaddict.com', N'Test')
SET IDENTITY_INSERT [User] OFF
GO

DBCC CHECKIDENT ([User], reseed, 1)
DBCC CHECKIDENT ([User], reseed)
GO

CREATE TABLE [Event] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[Name] NVARCHAR(255) NOT NULL,
	[UserId] INT NOT NULL,
	CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_Event_Name] UNIQUE ([Name]),
	CONSTRAINT [FK_Event_User] FOREIGN KEY ([UserId]) REFERENCES [User] ([Id])
)
GO

CREATE TABLE [CompetitorType] (
	[Id] NCHAR(1) NOT NULL,
	[Singular] NVARCHAR(255) NOT NULL,
	[Plural] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_CompetitorType] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_CompetitorType_Singular] UNIQUE ([Singular]),
	CONSTRAINT [UQ_CompetitorType_Plural] UNIQUE ([Plural])
)
GO

INSERT INTO [CompetitorType] ([Id], [Singular], [Plural])
VALUES
	(N'X', N'Competitor', N'Competitors'),
	(N'C', N'Couple', N'Couples'),
	(N'T', N'Team', N'Teams'),
	(N'W', N'Crew', N'Crews'),
	(N'G', N'Group', N'Groups'),
	(N'L', N'Leader', N'Leaders'),
	(N'F', N'Follower', N'Followers')
GO

CREATE TABLE [Division] (
	[EventId] INT NOT NULL,
	[Id] INT NOT NULL IDENTITY (1, 1),
	[Title] NVARCHAR(255) NOT NULL,
	[CompetitorTypeId] NCHAR(1) NOT NULL CONSTRAINT [DF_Division_CompetitorType] DEFAULT (N'X'),
	[SingleRound] BIT NOT NULL CONSTRAINT [DF_Division_SingleRound] DEFAULT (1),
	[GroupDance] BIT NOT NULL CONSTRAINT [DF_Division_GroupDance] DEFAULT (1),
	CONSTRAINT [PK_Division] PRIMARY KEY CLUSTERED ([EventId], [Id]),
	CONSTRAINT [UQ_Division_Id] UNIQUE ([Id]),
	CONSTRAINT [UQ_Division_Title] UNIQUE ([EventId], [Title]),
	CONSTRAINT [UQ_Division_SingleRound] UNIQUE ([Id], [SingleRound]),
	CONSTRAINT [UQ_Division_GroupDance] UNIQUE ([Id], [GroupDance]),
	CONSTRAINT [FK_Division_Event] FOREIGN KEY ([EventId]) REFERENCES [Event] ([Id]) ON DELETE CASCADE,
	CONSTRAINT [FK_Division_CompetitorType] FOREIGN KEY ([CompetitorTypeId]) REFERENCES [CompetitorType] ([Id])
)
GO

CREATE TABLE [Round] (
	[DivisionId] INT NOT NULL,
	[SingleRound] AS CONVERT(BIT, 0) PERSISTED,
	[Id] TINYINT NOT NULL,
	[PreviousId] AS CONVERT(TINYINT, NULLIF([Id] - 1, 0)) PERSISTED,
	[Title] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Round] PRIMARY KEY CLUSTERED ([DivisionId], [Id]),
	CONSTRAINT [UQ_Round_Title] UNIQUE ([DivisionId], [Title]),
	CONSTRAINT [FK_Round_Division] FOREIGN KEY ([DivisionId], [SingleRound]) REFERENCES [Division] ([Id], [SingleRound]) ON DELETE CASCADE,
	CONSTRAINT [FK_Round_Round] FOREIGN KEY ([DivisionId], [PreviousId]) REFERENCES [Round] ([DivisionId], [Id])
)
GO

CREATE TABLE [Criterion] (
	[DivisionId] INT NOT NULL,
	[GroupDance] AS CONVERT(BIT, 0) PERSISTED,
	[Id] TINYINT NOT NULL,
	[PreviousId] AS CONVERT(TINYINT, NULLIF([Id] - 1, 0)) PERSISTED,
	[Description] NVARCHAR(25) NOT NULL,
	[Min] TINYINT NOT NULL CONSTRAINT [DF_Criterion_Min] DEFAULT (0),
	[Max] TINYINT NOT NULL CONSTRAINT [DF_Criterion_Max] DEFAULT (10),
	[Deduction] BIT NOT NULL CONSTRAINT [DF_Criterion_Deduction] DEFAULT (0),
	CONSTRAINT [PK_Criterion] PRIMARY KEY CLUSTERED ([DivisionId], [Id], [Min], [Max], [Deduction]),
	CONSTRAINT [UQ_Criterion_Id] UNIQUE ([DivisionId], [Id]),
	CONSTRAINT [UQ_Criterion_Description] UNIQUE ([DivisionId], [Description]),
	CONSTRAINT [FK_Criterion_Division] FOREIGN KEY ([DivisionId], [GroupDance]) REFERENCES [Division] ([Id], [GroupDance]) ON DELETE CASCADE,
	CONSTRAINT [FK_Criterion_Criterion] FOREIGN KEY ([DivisionId], [PreviousId]) REFERENCES [Criterion] ([DivisionId], [Id]),
	CONSTRAINT [CK_Criterion_Min] CHECK ([Min] <= [Max]),
	CONSTRAINT [CK_Criterion_Max] CHECK ([Max] <= 100)
)
GO

CREATE TABLE [Heat] (
	[EventId] INT NOT NULL,
	[DivisionId] INT NOT NULL,
	[Id] INT NOT NULL IDENTITY (1, 1),
	[Title] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Heat] PRIMARY KEY CLUSTERED ([EventId], [DivisionId], [Id]),
	CONSTRAINT [UQ_Heat_Id] UNIQUE ([Id]),
	CONSTRAINT [UQ_Heat_Title] UNIQUE ([EventId], [DivisionId], [Title]),
	CONSTRAINT [FK_Heat_Division] FOREIGN KEY ([EventId], [DivisionId]) REFERENCES [Division] ([EventId], [Id]) ON DELETE CASCADE
)
GO

CREATE TABLE [Judge] (
	[EventId] INT NOT NULL,
	[DivisionId] INT NOT NULL,
	[HeatId] INT NOT NULL,
	[Id] INT NOT NULL,
	[Name] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Judge] PRIMARY KEY CLUSTERED ([EventId], [DivisionId], [HeatId], [Id]),
	CONSTRAINT [UQ_Judge_Name] UNIQUE ([EventId], [DivisionId], [HeatId], [Name]),
	CONSTRAINT [FK_Judge_Heat] FOREIGN KEY ([EventId], [DivisionId], [HeatId]) REFERENCES [Heat] ([EventId], [DivisionId], [Id]) ON DELETE CASCADE
)
GO

CREATE VIEW [Judges]
WITH SCHEMABINDING
AS
SELECT
	[EventId],
	[DivisionId],
	[HeatId],
	[Judges] = COUNT_BIG(*)
FROM [dbo].[Judge]
GROUP BY [EventId], [DivisionId], [HeatId]
GO

CREATE UNIQUE CLUSTERED INDEX [PK_Judges] ON [Judges] ([EventId], [DivisionId], [HeatId])
GO

CREATE TABLE [Competitor] (
	[EventId] INT NOT NULL,
	[DivisionId] INT NOT NULL,
	[HeatId] INT NOT NULL,
	[Id] INT NOT NULL,
	[Name] NVARCHAR(255) NOT NULL,
	[Withdrawn] BIT NOT NULL CONSTRAINT [DF_Competitor_Withdrawn] DEFAULT (0),
	[Disqualified] BIT NOT NULL CONSTRAINT [DF_Competitor_Disqualified] DEFAULT (0),
	CONSTRAINT [PK_Competitor] PRIMARY KEY CLUSTERED ([EventId], [DivisionId], [HeatId], [Id]),
	CONSTRAINT [UQ_Competitor_Name] UNIQUE ([EventId], [DivisionId], [HeatId], [Name]),
	CONSTRAINT [FK_Competitor_Heat] FOREIGN KEY ([EventId], [DivisionId], [HeatId]) REFERENCES [Heat] ([EventId], [DivisionId], [Id]) ON DELETE CASCADE,
	CONSTRAINT [CK_Competitor_Status] CHECK (NOT ([Withdrawn] & [Disqualified] = 1))
)
GO

CREATE VIEW [Competitors]
WITH SCHEMABINDING
AS
SELECT
	[EventId],
	[DivisionId],
	[HeatId],
	[Competitors] = COUNT_BIG(*)
FROM [dbo].[Competitor]
GROUP BY [EventId], [DivisionId], [HeatId]
GO

CREATE UNIQUE CLUSTERED INDEX [PK_Competitors] ON [Competitors] ([EventId], [DivisionId], [HeatId])
GO

CREATE VIEW [Heats]
WITH SCHEMABINDING
AS
SELECT
	[EventId] = h.[EventId],
	[DivisionId] = h.[DivisionId],
	[HeatId] = h.[Id],
	[Judges] = ISNULL(js.[Judges], 0),
	[Majority] = ISNULL(CONVERT(INT, ROUND(js.[Judges] / 2.0, 0) + (1 - js.[Judges] % 2)), 0),
	[Competitors] = ISNULL(cs.[Competitors], 0)
FROM [dbo].[Heat] h
	LEFT JOIN [dbo].[Judges] js (NOEXPAND) ON h.[EventId] = js.[EventId] AND h.[DivisionId] = js.[DivisionId] AND h.[Id] = js.[HeatId]
	LEFT JOIN [dbo].[Competitors] cs (NOEXPAND) ON h.[EventId] = cs.[EventId] AND h.[DivisionId] = cs.[DivisionId] AND h.[Id] = cs.[HeatId]
GO

CREATE TABLE [Score] (
	[EventId] INT NOT NULL,
	[DivisionId] INT NOT NULL,
	[HeatId] INT NOT NULL,
	[JudgeId] INT NOT NULL,
	[CompetitorId] INT NOT NULL,
	[CriterionId] TINYINT NOT NULL,
	[Min] TINYINT NOT NULL,
	[Max] TINYINT NOT NULL,
	[Deduction] BIT NOT NULL,
	[Value] TINYINT NOT NULL,
	[Total] AS [Value] * POWER(-1, [Deduction]) PERSISTED,
	CONSTRAINT [PK_Score] PRIMARY KEY CLUSTERED ([EventId], [DivisionId], [HeatId], [JudgeId], [CompetitorId], [CriterionId]),
	CONSTRAINT [FK_Score_Heat] FOREIGN KEY ([EventId], [DivisionId], [HeatId]) REFERENCES [Heat] ([EventId], [DivisionId], [Id]) ON DELETE CASCADE,
	CONSTRAINT [FK_Score_Judge] FOREIGN KEY ([EventId], [DivisionId], [HeatId], [JudgeId]) REFERENCES [Judge] ([EventId], [DivisionId], [HeatId], [Id]),
	CONSTRAINT [FK_Score_Competitor] FOREIGN KEY ([EventId], [DivisionId], [HeatId], [CompetitorId]) REFERENCES [Competitor] ([EventId], [DivisionId], [HeatId], [Id]),
	CONSTRAINT [FK_Score_Criterion] FOREIGN KEY ([DivisionId], [CriterionId], [Min], [Max], [Deduction]) REFERENCES [Criterion] ([DivisionId], [Id], [Min], [Max], [Deduction]),
	CONSTRAINT [CK_Score_Min] CHECK ([Value] >= [Min]),
	CONSTRAINT [CK_Score_Max] CHECK ([Value] <= [Max])
)
GO

CREATE VIEW [Scores]
WITH SCHEMABINDING
AS
SELECT
	[EventId],
	[DivisionId],
	[HeatId],
	[JudgeId],
	[CompetitorId],
	[Criteria] = COUNT_BIG(*),
	[Total] = SUM(ISNULL([Total], 0))
FROM [dbo].[Score]
GROUP BY [EventId], [DivisionId], [HeatId], [JudgeId], [CompetitorId]
GO

CREATE UNIQUE CLUSTERED INDEX [PK_Scores] ON [Scores] ([EventId], [DivisionId], [HeatId], [JudgeId], [CompetitorId])
GO

SET IDENTITY_INSERT [Event] ON
INSERT INTO [Event] ([Id], [Name], [UserId])
OUTPUT [inserted].*
VALUES (1, N'BOS Social Dance Competition', 0)
SET IDENTITY_INSERT [Event] OFF
GO

SET IDENTITY_INSERT [Division] ON
INSERT INTO [Division] ([EventId], [Id], [Title], [CompetitorTypeId], [SingleRound], [GroupDance])
OUTPUT [inserted].*
VALUES (1, 1, N'Leaders', N'L', 1, 1)
SET IDENTITY_INSERT [Division] OFF
GO

SET IDENTITY_INSERT [Heat] ON
INSERT INTO [Heat] ([EventId], [DivisionId], [Id], [Title])
OUTPUT [inserted].*
VALUES
	(1, 1, 1, N'Remix'),
	(1, 1, 2, N'Traditional'),
	(1, 1, 3, N'Dance with the Judges')
SET IDENTITY_INSERT [Heat] OFF
GO

INSERT INTO [Judge] ([EventId], [DivisionId], [HeatId], [Id], [Name])
OUTPUT [inserted].*
VALUES
	(1, 1, 1, 1, N'Biskit'),
	(1, 1, 1, 2, N'Alex'),
	(1, 1, 1, 3, N'Pierre'),
	(1, 1, 2, 1, N'Biskit'),
	(1, 1, 2, 2, N'Alex'),
	(1, 1, 2, 3, N'Pierre'),
	(1, 1, 3, 1, N'Angela'),
	(1, 1, 3, 2, N'Pebbles'),
	(1, 1, 3, 3, N'Crowd')
GO

