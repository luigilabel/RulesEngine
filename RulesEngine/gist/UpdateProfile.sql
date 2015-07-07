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
					,RG.[Enabled]      = T.[Enabled]
					,RG.ModifyByUserID = @UserID
					,RG.ModifyDate     = GETUTCDATE()
				FROM [dbo].[RuleGroup] RG INNER JOIN #groups T
				ON T.RuleGroupID = @groupID AND (RG.DisplayOrder != T.DisplayOrder OR RG.[Enabled] != T.[Enabled]);
							
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
					,RD.[Enabled]         = R.[Enabled]
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


