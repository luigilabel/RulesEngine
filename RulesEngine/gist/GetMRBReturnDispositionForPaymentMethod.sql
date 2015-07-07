CREATE PROCEDURE [dbo].[GetMRBReturnDispositionForPaymentMethod](
	 @xml xml(content RuleType)
	,@partMRBID int
	,@output bit OUTPUT
	) 
AS 
BEGIN
	SELECT T.c.value('.','nvarchar(20)') AS paymentMethod
	INTO #temp 
	FROM   @xml.nodes('/Rule/PaymentConfiguration/PaymentMethod') T(c);

	DECLARE @returnDisp bit= (select T.c.value('.','bit') as ret from @xml.nodes('/Rule/Return') T(c));
	select @returnDisp as [Return];

	DECLARE @MRBPaymentMethod nvarchar(100) = (
		select 
			PayMethod
			
		--from WarpDMS.dbo.PayMethod as PM 
		from PayMethod as PM 
			
		--inner join WarpDMS.dbo.RepairOrderJob as ROJ on PM.PayMethodID = ROJ.PayMethodID
		inner join RepairOrderJob as ROJ on PM.PayMethodID = ROJ.PayMethodID
			
		inner join PartMRB as PA on  ROJ.RepairOrderJobID = PA.RepairOrderJobID
			where PA.PartMRBID = @partMRBID and PA.MRBSourceID = 1
		);
	SET @output = 0;

	IF (
			(
				(@MRBPaymentMethod in (select paymentMethod from #temp) AND @returnDisp=1)
				OR 
				(@MRBPaymentMethod not in (select paymentMethod from #temp) AND @returnDisp = 0)
			)
			AND (@MRBPaymentMethod IS NOT NULL) 
			)
			SET @output  = 1;

	--Select @output as Result;

	DROP TABLE #temp;
END
GO