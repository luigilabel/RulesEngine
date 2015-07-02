CREATE PROCEDURE [dbo].[ThrowException]
AS BEGIN
	DECLARE @errorMessage nvarchar(4000),	@errorSeverity int
	SELECT @errorMessage = ERROR_MESSAGE(),	@errorSeverity = ERROR_SEVERITY()
	RAISERROR(@errorMessage, @errorSeverity, 1)
END
GO