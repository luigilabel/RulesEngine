/****** Object:  UserDefinedTableType [dbo].[RulesTableType]    Script Date: 24/06/2015 06:41:04 p. m. ******/
CREATE TYPE [dbo].[RulesTableType] AS TABLE(
	[RuleTypeID] [int] NOT NULL,
	[GroupGuid] [char](32) NOT NULL,
	[RuleConfiguration] [xml] NOT NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[RulesGroupTableType]    Script Date: 24/06/2015 06:40:59 p. m. ******/
CREATE TYPE [dbo].[RulesGroupTableType] AS TABLE(
	[GroupGuid] [char](32) NOT NULL,
	[GroupDescription] [varchar](100) NOT NULL
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
	 @ProfileName varchar(50)
	,@Groups dbo.RulesGroupTableType READONLY
	,@Rules dbo.RulesTableType READONLY
)
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN

		INSERT INTO RulesProfile (Name) 
		VALUES (@ProfileName)
		
		declare @ProfileID int = scope_identity()
		
		select *
		into #groups
		from @Groups -- temp aux table used to iterate over groups

		while exists (select 1 from #groups) begin
			declare @guid varchar(50) = (select top 1 GroupGuid from #groups)

			select @guid

			INSERT INTO RulesGroup (GroupDescription, ProfileID)
			SELECT [GroupDescription],@ProfileID
			FROM @Groups 
			WHERE [GroupGuid] = @guid

			declare @groupID int = scope_identity()

			INSERT INTO RuleDetail (RuleTypeID, GroupID, RuleConfiguration)
			SELECT [RuleTypeID], @groupID, [RuleConfiguration]
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