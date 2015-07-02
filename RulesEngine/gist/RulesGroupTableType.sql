CREATE TYPE [dbo].[RulesGroupTableType] AS TABLE(
	[RuleGroupID] [int] NULL,
	[GroupGuid] [char](32) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[Enabled] [bit] NOT NULL
)
GO