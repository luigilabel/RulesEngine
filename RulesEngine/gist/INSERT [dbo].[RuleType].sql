SET IDENTITY_INSERT [dbo].[RuleType] ON 
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (1, N'Payment Method', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (2, N'Region', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (3, N'Quantity', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (4, N'Schedule', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[RuleType] OFF
GO