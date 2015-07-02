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