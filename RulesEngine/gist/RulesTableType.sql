CREATE TYPE [dbo].[RulesTableType] AS TABLE(
	[RuleDetailID] [int] NULL,
	[RuleTypeID] [int] NOT NULL,
	[GroupGuid] [char](32) NOT NULL,
	[RuleConfiguration] [xml] NOT NULL,
	[Enabled] [bit] NOT NULL
)
GO