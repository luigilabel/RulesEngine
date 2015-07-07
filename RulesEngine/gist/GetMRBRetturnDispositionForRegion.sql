CREATE PROCEDURE [dbo].[GetMRBRetturnDispositionForRegion](
	 @xml xml(content RuleType)
	 ,@partMRBID int
	 ,@output bit OUTPUT
	)
AS 
BEGIN
	BEGIN TRY
		SELECT T.c.value('.','nvarchar(20)') AS region
		INTO #temp 
		FROM   @xml.nodes('/Rule/RegionConfiguration/Region') T(c);

		DECLARE @returnDisp bit= (select T.c.value('.','bit') as region from @xml.nodes('/Rule/Return') T(c));

		DECLARE @partRegion nvarchar(20) = (
			select Region 
			from LocationAttribute as LA 
			join PartMRB PA on LA.LocationID = MRBCreatedLocationID 
			where PA.PartMRBID = @partMRBID 
			);

		SET @output = 0;

		IF ((@partRegion in (select region from #temp) AND @returnDisp=1) OR (@partRegion not in (select region from #temp) AND @returnDisp = 0) )	
				set @output  = 1;

		DROP TABLE #temp;

	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		EXEC ThrowException
	END CATCH
END
GO


