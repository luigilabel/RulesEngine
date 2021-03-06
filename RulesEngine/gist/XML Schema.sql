USE [RuleEngine]
GO

/****** Object:  XmlSchemaCollection [dbo].[RuleType]    Script Date: 07/07/2015 03:56:40 p. m. ******/
 XML SCHEMA COLLECTION [dbo].[RuleType] AS N'
	<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
		<xsd:element name="Rule">
			<xsd:complexType>
				<xsd:complexContent>
					<xsd:restriction base="xsd:anyType">
						<xsd:sequence>
							<xsd:element name="Type" type="Rule" />
							<xsd:element name="Return" type="xsd:boolean" />
								<xsd:choice>
									<xsd:element name="PaymentConfiguration" type="PaymentMethodRule" />
									<xsd:element name="RegionConfiguration" type="RegionRule" />
									<xsd:element name="Quantity" type="xsd:integer" />
									<xsd:element name="ScheduleConfiguration" type="ScheduleRule" />
								</xsd:choice>
							<xsd:element name="From" type="xsd:time" minOccurs="0" />
							<xsd:element name="To" type="xsd:time" minOccurs="0" />
						</xsd:sequence>
					</xsd:restriction>
				</xsd:complexContent>
			</xsd:complexType>
		</xsd:element>
		<xsd:complexType name="PaymentMethodRule">
			<xsd:complexContent>
				<xsd:restriction base="xsd:anyType">
					<xsd:sequence>
						<xsd:element name="PaymentMethod" type="xsd:string" maxOccurs="13" />
					</xsd:sequence>
				</xsd:restriction>
			</xsd:complexContent>
		</xsd:complexType>
		<xsd:complexType name="RegionRule">
			<xsd:complexContent>
				<xsd:restriction base="xsd:anyType">
					<xsd:sequence>
						<xsd:element name="Region" type="xsd:string" maxOccurs="3" />
					</xsd:sequence>
				</xsd:restriction>
			</xsd:complexContent>
		</xsd:complexType>
		<xsd:complexType name="ScheduleRule">
			<xsd:complexContent>
				<xsd:restriction base="xsd:anyType">
					<xsd:sequence>
						<xsd:element name="Day" type="xsd:string" maxOccurs="7" />
					</xsd:sequence>
				</xsd:restriction>
			</xsd:complexContent>
		</xsd:complexType>
		<xsd:simpleType name="Rule">
			<xsd:restriction base="xsd:string">
				<xsd:enumeration value="PaymentMethod" />
				<xsd:enumeration value="Region" />
				<xsd:enumeration value="QuantityNeeded" />
				<xsd:enumeration value="Schedule" />
			</xsd:restriction>
		</xsd:simpleType>
	</xsd:schema>'
GO