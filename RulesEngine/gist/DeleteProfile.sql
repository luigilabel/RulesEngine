CREATE PROCEDURE [dbo].[DeleteProfile] (
	 @ProfileID int
	 ,@UserID int
)
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN

		SELECT *
		INTO #groups
		FROM RuleGroup WHERE RuleProfileID = @ProfileID -- temp aux table used to iterate over groups

		WHILE exists (select 1 from #groups) begin
			DECLARE @GroupID int = (select top 1 RuleGroupID from #groups)

			UPDATE RuleDetail SET 
				 Enabled = 0
				,ModifyByUserID = @UserID
				,ModifyDate = getutcdate()
			WHERE RuleGroupID = @GroupID

			DELETE #groups WHERE RuleGroupID = @GroupID
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