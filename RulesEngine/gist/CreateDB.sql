CREATE XML SCHEMA COLLECTION [dbo].[RuleType] AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"><xsd:element name="Rule"><xsd:complexType><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="Type" type="Rule" /><xsd:element name="Return" type="xsd:boolean" /><xsd:choice><xsd:element name="PaymentConfiguration" type="PaymentMethodRule" /><xsd:element name="RegionConfiguration" type="RegionRule" /><xsd:element name="Quantity" type="xsd:integer" /><xsd:element name="ScheduleConfiguration" type="ScheduleRule" /></xsd:choice><xsd:element name="From" type="xsd:time" minOccurs="0" /><xsd:element name="To" type="xsd:time" minOccurs="0" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType></xsd:element><xsd:complexType name="PaymentMethodRule"><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="PaymentMethod" type="xsd:string" maxOccurs="5" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType><xsd:complexType name="RegionRule"><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="Region" type="xsd:string" maxOccurs="3" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType><xsd:complexType name="ScheduleRule"><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="Day" type="xsd:string" maxOccurs="7" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType><xsd:simpleType name="Rule"><xsd:restriction base="xsd:string"><xsd:enumeration value="PaymentMethod" /><xsd:enumeration value="Region" /><xsd:enumeration value="QuantityNeeded" /><xsd:enumeration value="Schedule" /></xsd:restriction></xsd:simpleType></xsd:schema>'
GO


CREATE TYPE [dbo].[RulesGroupTableType] AS TABLE(
	[RuleGroupID] [int] NULL,
	[GroupGuid] [char](32) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsEnabled] [bit] NOT NULL
)
GO


CREATE TYPE [dbo].[RulesTableType] AS TABLE(
	[RuleDetailID] [int] NULL,
	[RuleTypeID] [int] NOT NULL,
	[GroupGuid] [char](32) NOT NULL,
	[RuleConfiguration] [xml] NOT NULL,
	[IsEnabled] [bit] NOT NULL
)
GO


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


CREATE TABLE [dbo].[RuleProfile](
	[RuleProfileID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Profile] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesProfile_CreateDate]  DEFAULT (getutcdate()),
	[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_RulesProfile_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL 
)
GO


CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleProfile_Name_IsEnabled] ON [dbo].[RuleProfile]
(
	[Name] ASC,
	[IsEnabled] ASC
)
WHERE ([IsEnabled]=(1))
GO


CREATE TABLE [dbo].[RuleGroup](
	[RuleGroupID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED,
	[RuleProfileID] [int] NOT NULL CONSTRAINT [FK_Group_Profile] FOREIGN KEY([RuleProfileID]) REFERENCES [dbo].[RuleProfile] ([RuleProfileID]),
	[IsSystem] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesGroup_CreateDate] DEFAULT (getutcdate()),
	[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_RulesGroup_Enabled] DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL
)
GO


CREATE TABLE [dbo].[RuleDetail](
	[RuleDetailID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_RuleDetail] PRIMARY KEY CLUSTERED,
	[RuleTypeID] [int] NOT NULL CONSTRAINT [FK_RuleDetail_RuleType] FOREIGN KEY([RuleTypeID]) REFERENCES [dbo].[RuleType] ([RuleTypeID]),
	[RuleGroupID] [int] NOT NULL CONSTRAINT [FK_Rule_Group] FOREIGN KEY([RuleGroupID]) REFERENCES [dbo].[RuleGroup] ([RuleGroupID]),
	[RuleConfiguration] [xml](CONTENT [dbo].[RuleType]) NOT NULL,
	[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_RuleDetail_Enabled]  DEFAULT ((1)),
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


CREATE PROCEDURE [dbo].[ThrowException]
AS BEGIN
	DECLARE @errorMessage nvarchar(4000),	@errorSeverity int
	SELECT @errorMessage = ERROR_MESSAGE(),	@errorSeverity = ERROR_SEVERITY()
	RAISERROR(@errorMessage, @errorSeverity, 1)
END
GO


CREATE PROCEDURE [dbo].[CreateProfile] (
	 @UserID int
	,@ProfileID int
	,@ProfileName varchar(50)
	,@Groups dbo.RulesGroupTableType READONLY
	,@Rules dbo.RulesTableType READONLY
)
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN

		INSERT INTO RuleProfile (Name, CreateByUserID) 
		VALUES (@ProfileName, @UserID)
		
		declare @newProfileID int = scope_identity()
		
		select * into #groups from @Groups -- temp aux table used to iterate over groups

		while exists (select 1 from #groups) begin
			declare @guid varchar(50) = (select top 1 GroupGuid from #groups)

			INSERT INTO [dbo].[RuleGroup]
			   ([RuleProfileID]
			   ,[IsSystem]
			   ,[DisplayOrder]
			   ,[CreateByUserID])
			SELECT
			    @newProfileID
			   ,IsSystem
			   ,DisplayOrder
			   ,@UserID
			FROM @Groups 
			WHERE [GroupGuid] = @guid

			declare @groupID int = scope_identity()

			INSERT INTO [dbo].[RuleDetail]
				([RuleTypeID]
				,[RuleGroupID]
				,[RuleConfiguration]
				,[CreateByUserID])
			SELECT
				 RuleTypeID
				,@groupID
				,RuleConfiguration
				,@UserID
			FROM @Rules
			WHERE [GroupGuid] = @guid

			delete #groups where [GroupGuid] = @guid
		end

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		EXEC ThrowException
	END CATCH
END
GO


CREATE PROCEDURE [dbo].[DeleteProfile] (
	 @ProfileID int
	 ,@UserID int
)
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN

		select *
		into #groups
		from RuleGroup where RuleProfileID = @ProfileID -- temp aux table used to iterate over groups

		while exists (select 1 from #groups) begin
			declare @GroupID int = (select top 1 RuleGroupID from #groups)

			UPDATE RuleDetail SET 
				 IsEnabled = 0
				,ModifyByUserID = @UserID
				,ModifyDate = getutcdate()
			WHERE RuleGroupID = @GroupID

			delete #groups where RuleGroupID = @GroupID
		end

		UPDATE RuleGroup SET 
			 IsEnabled = 0
			,ModifyByUserID = @UserID
			,ModifyDate = getutcdate()
		WHERE RuleProfileID = @ProfileID

		UPDATE RuleProfile SET 
			IsEnabled = 0
			,ModifyByUserID = @UserID
			,ModifyDate = getutcdate()
		WHERE RuleProfileID = @ProfileID

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		EXEC ThrowException
	END CATCH
END
GO


Create PROCEDURE [dbo].[ReadProfile]
	(@ProfileID int)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * FROM RuleProfile WHERE RuleProfileID = @ProfileID
	SELECT * FROM RuleGroup WHERE RuleProfileID = @ProfileID
	SELECT * FROM RuleDetail WHERE RuleGroupID in ( SELECT RuleGroupID FROM RuleGroup WHERE RuleProfileID = @ProfileID)

END
GO


CREATE PROCEDURE [dbo].[UpdateProfile] (
	 @UserID int
	,@ProfileID int
	,@ProfileName varchar(50)
	,@Groups dbo.RulesGroupTableType READONLY
	,@Rules dbo.RulesTableType READONLY
)
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN
		--Verify if its needed to update the name of the profile
		IF(SELECT Name FROM RuleProfile WHERE RuleProfileID = @ProfileID) != @ProfileName
		BEGIN
			UPDATE RuleProfile SET 
				 Name           = @ProfileName
				,ModifyByUserID = @UserID
				,ModifyDate     = GETUTCDATE()
			WHERE RuleProfileID = @ProfileID
		END

		SELECT * 
		INTO #groups 
		FROM @Groups -- temp aux table used to iterate over groups
		
		WHILE exists (SELECT 1 FROM #groups) 
		BEGIN
			DECLARE @groupGuid varchar(50) = (select top 1 GroupGuid from #groups)
			DECLARE @groupID int = (select RuleGroupID from #groups where GroupGuid= @groupGuid)
			
			IF (@groupID = 0)
			BEGIN
				-- Insert all the new groups
				INSERT INTO [dbo].[RuleGroup]
					([RuleProfileID]
					,[IsSystem]
					,[DisplayOrder]
					,[CreateByUserID])
				SELECT
					 @ProfileID
					,IsSystem
					,DisplayOrder
					,@UserID
				FROM #Groups AS T 
				WHERE [GroupGuid] = @groupGuid AND T.RuleGroupID=0
				
				DECLARE @newGroupID int = scope_identity();

				-- Insert all the new rules of all the new groups
				INSERT INTO [dbo].[RuleDetail]
					([RuleTypeID]
					,[RuleGroupID]
					,[RuleConfiguration]
					,[CreateByUserID])
				SELECT
					 RuleTypeID
					,@newGroupID
					,RuleConfiguration
					,@UserID
				FROM @Rules
				WHERE [GroupGuid] = @groupGuid;
			END
			ELSE
			BEGIN
				
				-- Update all existing groups that changed its display order or enabled status		 
				UPDATE RG SET  
					 RG.DisplayOrder   = T.DisplayOrder
					,RG.[IsEnabled]      = T.[IsEnabled]
					,RG.ModifyByUserID = @UserID
					,RG.ModifyDate     = GETUTCDATE()
				FROM [dbo].[RuleGroup] RG INNER JOIN #groups T
				ON T.RuleGroupID = @groupID AND (RG.DisplayOrder != T.DisplayOrder OR RG.[IsEnabled] != T.[IsEnabled]);
							
				-- insert new rules into preexisting groups
				INSERT INTO [dbo].[RuleDetail]
					([RuleTypeID]
					,[RuleGroupID]
					,[RuleConfiguration]
					,[CreateByUserID])
				SELECT
					 RuleTypeID
					,@groupID
					,RuleConfiguration
					,@UserID
				FROM @Rules AS R
				WHERE R.GroupGuid = @groupGuid AND R.RuleDetailID = 0;

				-- Update older rules
				UPDATE RD SET 
					 RD.RuleConfiguration = R.RuleConfiguration
					,RD.[IsEnabled]         = R.[IsEnabled]
					,RD.ModifyByUserID    = @UserID
					,RD.ModifyDate        = GETUTCDATE()
				FROM [dbo].[RuleDetail] RD INNER JOIN @Rules R
				ON RD.RuleDetailID = R.RuleDetailID AND [GroupGuid] = @groupGuid AND R.RuleDetailID != 0

				UPDATE RG SET  
					 RG.ModifyByUserID = @UserID
					,RG.ModifyDate     = GETUTCDATE()
				FROM [dbo].[RuleGroup] RG INNER JOIN #groups T
				ON T.RuleGroupID = @groupID;

			END;
			DELETE #groups WHERE [GroupGuid] = @groupGuid;
		END;
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		EXEC ThrowException
	END CATCH
END
GO
                                    

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

