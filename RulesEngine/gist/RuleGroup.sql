CREATE TABLE [dbo].[RuleGroup](
	[RuleGroupID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED,
	[RuleProfileID] [int] NOT NULL CONSTRAINT [FK_Group_Profile] FOREIGN KEY([RuleProfileID]) REFERENCES [dbo].[RuleProfile] ([RuleProfileID]),
	[IsSystem] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RulesGroup_Enabled]  DEFAULT ((1)),
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesGroup_CreateDate]  DEFAULT (getutcdate()),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL,
)
GO
