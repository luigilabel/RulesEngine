CREATE PROCEDURE [dbo].[ReadProfile]
	(@ProfileID int)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		 RuleProfileID as ID
		,Name
		,Enabled as IsEnabled
	FROM RuleProfile 
	WHERE RuleProfileID = @ProfileID
	
	SELECT
		 RuleGroupID as ID
		,RuleProfileID as ProfileID
		,IsSystem
		,DisplayOrder
		,Enabled as IsEnabled
	FROM RuleGroup 
	WHERE RuleProfileID = @ProfileID

	SELECT 
		 RuleDetailID as ID
		,RuleTypeID 
		,RuleGroupID
		,RuleConfiguration
		,Enabled as IsEnabled
	FROM RuleDetail 
	WHERE RuleGroupID in ( SELECT RuleGroupID FROM RuleGroup WHERE RuleProfileID = @ProfileID)

END
GO