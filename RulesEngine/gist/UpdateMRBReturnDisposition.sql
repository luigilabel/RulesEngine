CREATE PROCEDURE [dbo].[UpdateMRBReturnDisposition]
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
				
		select * into #partMRB from PartMRB

		WHILE EXISTS (select 1 from #partMRB) 
		BEGIN
			DECLARE @partMRBID int = (select top 1 PartMRBID from #partMRB)
			--select @partMRBID
			IF EXISTS(select ProfileID from #partMRB join PartInfo as [PI] on [PI].PartID = #partMRB.PartID)
			BEGIN
				SELECT * INTO #groups FROM RuleGroup WHERE RuleProfileID IN(select ProfileID from #partMRB join PartInfo as [PI] on [PI].PartID = #partMRB.PartID )
				--Select COUNT(*) FROM #groups as thisGroups
				DECLARE @profileResult bit = 0
				--select @profileResult
			
									WHILE EXISTS ( select 1 from #groups) 
									BEGIN 
										DECLARE @groupID int = ( select top 1 RuleGroupID from #groups)
										SELECT RD.RuleDetailID, RD.RuleGroupID, RD.RuleTypeID INTO #rules FROM  RuleDetail as RD WHERE RuleGroupID = @groupID
										DECLARE @groupResult bit = 1

															WHILE EXISTS (select 1 from #rules)
															BEGIN
																DECLARE @ruleDetailID int = (select top 1 RuleDetailID from #rules)
																DECLARE @ruleType varchar(50) = (select top 1 Name from #rules as R join RuleType as RT on R.RuleTypeID = RT.RuleTypeID)
																DECLARE @ruleResult bit = 0;
																DECLARE @xml xml(CONTENT Ruletype) = (select RuleConfiguration from RuleDetail where RuleDetailID = @ruleDetailID)
																Declare @returnStatus int;
																IF ( @RuleType = 'Payment Method')
																BEGIN
																	EXEC  @returnStatus =  GetMRBReturnDispositionForPaymentMethod @xml, @partMRBID, @ruleResult OUTPUT
																END
																IF ( @RuleType = 'Region')
																BEGIN
																	EXEC  @returnStatus =  GetMRBRetturnDispositionForRegion @xml, @partMRBID, @ruleResult OUTPUT
																END
																SET @groupResult = @groupResult & @ruleResult
																DELETE #rules WHERE RuleDetailID = @ruleDetailID;
															END
										SET   @profileResult=  @profileResult | @groupResult
										DROP TABLE #rules
										DELETE #groups WHERE RuleGroupID = @groupID;
									END
				DROP TABLE #groups
				UPDATE PMRB SET
				ReturnDisposition = @profileResult
				FROM PartMRB as PMRB WHERE PartMRBID = @partMRBID
			END
			DELETE #partMRB WHERE PartMRBID = @partMRBID
		END
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		EXEC ThrowException
	END CATCH
END

GO


