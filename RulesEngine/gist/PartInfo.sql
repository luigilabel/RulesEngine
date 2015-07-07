
CREATE TABLE [dbo].[PartInfo](
	[PartInfoID] [int] IDENTITY(1,1) NOT NULL,
	[PartID] [int] NOT NULL,
	[ProfileID] [int] NOT NULL,
	[PartNumber] [varchar](100) NOT NULL,
	[PartDescription] [varchar](200) NOT NULL
) ON [PRIMARY]

GO
