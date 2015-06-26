
/****** Object:  Database [WSO_RulesEngine]    Script Date: 26/06/2015 11:57:35 a. m. ******/
CREATE DATABASE [RulesEngine]
GO
USE RulesEngine
go
/****** Object:  XmlSchemaCollection [dbo].[RuleType]    Script Date: 26/06/2015 11:57:35 a. m. ******/
CREATE XML SCHEMA COLLECTION [dbo].[RuleType] AS N'
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <xsd:element name="Rule">
        <xsd:complexType>
            <xsd:complexContent>
                <xsd:restriction base="xsd:anyType">
                    <xsd:sequence>
                        <xsd:element name="Type" type="Rule" />
                        <xsd:element name="Return" type="xsd:boolean" />
                        <xsd:choice>
                            <xsd:element name="PaymentConfiguration" type="PaymentMethodRule" />
                            <xsd:element name="RegionConfiguration" type="RegionRule" />
                            <xsd:element name="QuantityConfiguration" type="xsd:integer" />
                            <xsd:element name="ScheduleConfiguration" type="ScheduleRule" />
                        </xsd:choice>
                        <xsd:element name="From" type="xsd:time" minOccurs="0" />
                        <xsd:element name="To" type="xsd:time" minOccurs="0" />
                    </xsd:sequence>
                </xsd:restriction>
            </xsd:complexContent>
        </xsd:complexType>
    </xsd:element>
    <xsd:complexType name="PaymentMethodRule">
        <xsd:complexContent>
            <xsd:restriction base="xsd:anyType">
                <xsd:sequence>
                    <xsd:element name="PaymentMethod" type="xsd:string" maxOccurs="5" />
                </xsd:sequence>
            </xsd:restriction>
        </xsd:complexContent>
    </xsd:complexType>
    <xsd:complexType name="RegionRule">
        <xsd:complexContent>
            <xsd:restriction base="xsd:anyType">
                <xsd:sequence>
                    <xsd:element name="Region" type="xsd:string" maxOccurs="3" />
                </xsd:sequence>
            </xsd:restriction>
        </xsd:complexContent>
    </xsd:complexType>
    <xsd:complexType name="ScheduleRule">
        <xsd:complexContent>
            <xsd:restriction base="xsd:anyType">
                <xsd:sequence>
                    <xsd:element name="Day" type="xsd:string" maxOccurs="7" />
                </xsd:sequence>
            </xsd:restriction>
        </xsd:complexContent>
    </xsd:complexType>
    <xsd:simpleType name="Rule">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="PaymentMethod" />
            <xsd:enumeration value="Region" />
            <xsd:enumeration value="QuantityNeeded" />
            <xsd:enumeration value="Schedule" />
        </xsd:restriction>
    </xsd:simpleType>
</xsd:schema>'
GO
/****** Object:  UserDefinedTableType [dbo].[RulesGroupTableType]    Script Date: 26/06/2015 11:57:35 a. m. ******/
CREATE TYPE [dbo].[RulesGroupTableType] AS TABLE(
	[GroupGuid] [char](32) NOT NULL,
	[IsSystem] [bit] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[RulesTableType]    Script Date: 26/06/2015 11:57:35 a. m. ******/
CREATE TYPE [dbo].[RulesTableType] AS TABLE(
	[RuleTypeID] [int] NOT NULL,
	[GroupGuid] [char](32) NOT NULL,
	[RuleConfiguration] [xml] NOT NULL
)
GO
/****** Object:  StoredProcedure [dbo].[CreateProfile]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE PROCEDURE [dbo].[CreateProfile] (
	 @UserID int
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
		
		declare @ProfileID int = scope_identity()
		
		select * into #groups from @Groups -- temp aux table used to iterate over groups

		while exists (select 1 from #groups) begin
			declare @guid varchar(50) = (select top 1 GroupGuid from #groups)

			INSERT INTO [dbo].[RuleGroup]
			   ([RuleProfileID]
			   ,[IsSystem]
			   ,[CreateByUserID])
			SELECT
			    @ProfileID
			   ,IsSystem
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
/****** Object:  StoredProcedure [dbo].[DeleteProfile]    Script Date: 26/06/2015 11:57:35 a. m. ******/

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
				 Enabled = 0
				,ModifyByUserID = @UserID
				,ModifyDate = getutcdate()
			WHERE RuleGroupID = @GroupID

			delete #groups where RuleGroupID = @GroupID
		end

		UPDATE RuleGroup SET 
			 Enabled = 0
			,ModifyByUserID = @UserID
			,ModifyDate = getutcdate()
		WHERE RuleProfileID = @ProfileID

		UPDATE RuleProfile SET 
			Enabled = 0
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
/****** Object:  StoredProcedure [dbo].[ThrowException]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE PROCEDURE [dbo].[ThrowException]
AS BEGIN
	DECLARE @errorMessage nvarchar(4000),	@errorSeverity int
	SELECT @errorMessage = ERROR_MESSAGE(),	@errorSeverity = ERROR_SEVERITY()
	RAISERROR(@errorMessage, @errorSeverity, 1)
END
GO
/****** Object:  Table [dbo].[RuleDetail]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE TABLE [dbo].[RuleDetail](
	[RuleDetailID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_RuleDetail] PRIMARY KEY CLUSTERED ,
	[RuleTypeID] [int] NOT NULL  CONSTRAINT [FK_RuleDetail_RuleType] FOREIGN KEY([RuleTypeID]) REFERENCES [dbo].[RuleType] ([RuleTypeID]),
	[RuleGroupID] [int] NOT NULL CONSTRAINT [FK_Rule_Group] FOREIGN KEY REFERENCES [dbo].[RuleGroup] ([RuleGroupID]),
	[RuleConfiguration] [xml](CONTENT [dbo].[RuleType]) NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RuleDetail_CreateDate]  DEFAULT (getutcdate()),
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RuleDetail_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleDetail_RuleTypeID_RuleGroupID] ON [dbo].[RuleDetail]
(
	[RuleGroupID] ASC,
	[RuleTypeID] ASC
)
GO
/****** Object:  Table [dbo].[RuleGroup]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE TABLE [dbo].[RuleGroup](
	[RuleGroupID] [int] IDENTITY(1,1) NOT NULL  CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED,
	[RuleProfileID] [int] NOT NULL CONSTRAINT [FK_Group_Profile] FOREIGN KEY REFERENCES [dbo].[RuleProfile] ([RuleProfileID]),
	[IsSystem] [bit] NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesGroup_CreateDate]  DEFAULT (getutcdate()),
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RulesGroup_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL)
GO
/****** Object:  Table [dbo].[RuleProfile]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE TABLE [dbo].[RuleProfile](
	[RuleProfileID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Profile] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RulesProfile_CreateDate]  DEFAULT (getutcdate()),
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RulesProfile_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_RuleProfile_Name_Enabled] ON [dbo].[RuleProfile]
(
	[Name] ASC,
	[Enabled] ASC
)
WHERE ([Enabled]=(1))
GO
/****** Object:  Table [dbo].[RuleType]    Script Date: 26/06/2015 11:57:35 a. m. ******/

CREATE TABLE [dbo].[RuleType](
	[RuleTypeID] [int] IDENTITY(1,1) NOT NULL  CONSTRAINT [PK_RuleType] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[CreateByUserID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_RuleType_CreateDate]  DEFAULT (getutcdate()),
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_RuleType_Enabled]  DEFAULT ((1)),
	[ModifyByUserID] [int] NULL,
	[ModifyDate] [datetime] NULL)
GO
                                    
SET IDENTITY_INSERT [dbo].[RuleType] ON 

GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (1, N'Payment Method', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (2, N'Region', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (3, N'Quantity', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[RuleType] ([RuleTypeID], [Name], [CreateByUserID], [CreateDate], [Enabled], [ModifyByUserID], [ModifyDate]) VALUES (4, N'Odometer', 1, CAST(N'2015-06-25 23:15:50.140' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[RuleType] OFF
GO