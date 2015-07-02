CREATE TABLE [dbo].[RuleProfile](
	[RuleProfileID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Profile] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RulesProfile_Enabled]  DEFAULT ((1)),
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesProfile_CreateDate]  DEFAULT (getutcdate()),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL
)
GO


CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleProfile_Name_Enabled] ON [dbo].[RuleProfile]
(
	[Name] ASC,
	[Enabled] ASC
)
WHERE ([Enabled]=(1))
GO