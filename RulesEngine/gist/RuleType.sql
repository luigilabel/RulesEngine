CREATE TABLE [dbo].[RuleType](
	[RuleTypeID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_RuleType] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RuleType_CreateDate]  DEFAULT (getutcdate()),
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RuleType_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL
)
GO


CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleType_Name_Enabled] ON [dbo].[RuleType]
(
	[Name] ASC,
	[Enabled] ASC
)
WHERE ([Enabled]=(1))
GO
