CREATE TABLE [dbo].[RuleDetail](
	[RuleDetailID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_RuleDetail] PRIMARY KEY CLUSTERED,
	[RuleTypeID] [int] NOT NULL CONSTRAINT [FK_RuleDetail_RuleType] FOREIGN KEY REFERENCES [dbo].[RuleType] ([RuleTypeID]),
	[RuleGroupID] [int] NOT NULL CONSTRAINT [FK_Rule_Group] FOREIGN KEY REFERENCES [dbo].[RuleGroup] ([RuleGroupID]),
	[RuleConfiguration] [xml](CONTENT [dbo].[RuleType]) NOT NULL,
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RuleDetail_Enabled]  DEFAULT ((1)),
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RuleDetail_CreateDate]  DEFAULT (getutcdate()),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleDetail_RuleTypeID_RuleGroupID] ON [dbo].[RuleDetail]
(
	[RuleGroupID] ASC,
	[RuleTypeID] ASC
)
GO