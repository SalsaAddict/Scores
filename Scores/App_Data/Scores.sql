--IF DB_ID(N'Scores') IS NOT NULL DROP DATABASE [Scores]; CREATE DATABASE [Scores]
USE [Scores]
GO

SET NOCOUNT ON
GO

IF OBJECT_ID(N'division', N'U') IS NOT NULL DROP TABLE [division]
IF OBJECT_ID(N'competitorType', N'U') IS NOT NULL DROP TABLE [competitorType]
IF OBJECT_ID(N'competition', N'U') IS NOT NULL DROP TABLE [competition]
GO

IF OBJECT_ID(N'pin', N'U') IS NULL
CREATE TABLE [pin] (
	[id] INT NOT NULL,
	[pin] NCHAR(6) NOT NULL,
	CONSTRAINT [pk_pin] PRIMARY KEY NONCLUSTERED ([pin]),
	CONSTRAINT [uq_pin_id] UNIQUE CLUSTERED ([id]),
	CONSTRAINT [ck_pin_pin] CHECK (CONVERT(INT, [pin]) BETWEEN 0 AND 999999)
)
GO

IF NOT EXISTS (SELECT * FROM [pin])
INSERT INTO [pin] ([id], [pin])
SELECT
	[id] = ROW_NUMBER() OVER (ORDER BY NEWID()),
	[pin] = RIGHT(REPLICATE(N'0', 6) + CONVERT(NVARCHAR(6), v1.[number] * 1000 + v2.[number]), 6)
FROM [master]..[spt_values] v1
	CROSS JOIN [master]..[spt_values] v2
WHERE v1.[type] = N'P' AND v2.[type] = N'P'
	AND v1.[number] BETWEEN 0 AND 999
	AND v2.[number] BETWEEN 0 AND 999
GO

CREATE TABLE [competition] (
	[id] INT NOT NULL IDENTITY (1, 1),
	[name] NVARCHAR(255) NOT NULL,
	[pin] NCHAR(6) NOT NULL,
	CONSTRAINT [pk_competition] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_competition_name] UNIQUE ([name]),
	CONSTRAINT [uq_competition_pin] UNIQUE ([pin]),
	CONSTRAINT [fk_competition_pin] FOREIGN KEY ([pin]) REFERENCES [pin] ([pin])
)
GO

CREATE TABLE [competitorType] (
	[id] NCHAR(1) NOT NULL,
	[single] NVARCHAR(25) NOT NULL,
	[plural] NVARCHAR(25) NOT NULL,
	CONSTRAINT [pk_competitorType] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_competitorType_single] UNIQUE ([single]),
	CONSTRAINT [uq_competitorType_plural] UNIQUE ([plural])
)
GO

INSERT INTO [CompetitorType] ([id], [single], [plural])
VALUES
	(N'X', N'Competitor', N'Competitors'),
	(N'C', N'Couple', N'Couples'),
	(N'L', N'Leader', N'Leaders'),
	(N'F', N'Follower', N'Followers'),
	(N'T', N'Team', N'Teams'),
	(N'W', N'Crew', N'Crews')
GO

CREATE TABLE [division] (
	[competitionId] INT NOT NULL,
	[id] INT NOT NULL IDENTITY (1, 1),
	[name] NVARCHAR(255) NOT NULL,
	[competitorTypeId] NCHAR(1) NOT NULL CONSTRAINT [df_division_competitorType] DEFAULT (N'X'),
	[singleRound] BIT NOT NULL CONSTRAINT [df_division_singleRound] DEFAULT (1),
	[groupDance] BIT NOT NULL CONSTRAINT [df_division_groupDance] DEFAULT (1),
	CONSTRAINT [pk_division] PRIMARY KEY CLUSTERED ([competitionId], [id]),
	CONSTRAINT [uq_division_id] UNIQUE ([id]),
	CONSTRAINT [uq_division_name] UNIQUE ([competitionId], [name]),
	CONSTRAINT [fk_division_competition] FOREIGN KEY ([competitionId]) REFERENCES [competition] ([id]) ON DELETE CASCADE,
	CONSTRAINT [fk_division_competitorType] FOREIGN KEY ([competitorTypeId]) REFERENCES [competitorType] ([id])
)
GO

CREATE TABLE [criterion] (
	[competitionId] INT NOT NULL,
	[divisionId] INT NOT NULL,
	[id] TINYINT NOT NULL,
	[title] NVARCHAR(25) NOT NULL,
	[description] NVARCHAR(255) NULL,
	[min] TINYINT NOT NULL,
	[max] TINYINT NOT NULL,
	[increment] TINYINT NOT NULL,

)
GO
