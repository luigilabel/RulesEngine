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
		
		DECLARE @newProfileID int = scope_identity()
		
		select * into #groups from @Groups -- temp aux table used to iterate over groups

		WHILE exists (select 1 from #groups) 
		BEGIN
			DECLARE @guid varchar(50) = (select top 1 GroupGuid from #groups)

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