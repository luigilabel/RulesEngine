CREATE XML SCHEMA COLLECTION RuleType
AS 
'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="Rule">
        <xs:complexType>
            <xs:sequence>
                <xs:element name="Type" type="Rule" />
                <xs:choice>
                    <xs:element name="PaymentConfiguration" type="PaymentMethodRule" />
                    <xs:element name="RegionConfiguration" type="RegionRule" />
                    <xs:element name="QuantityConfiguration" type="QuantityRule" />
                    <xs:element name="ScheduleConfiguration" type="ScheduleRule"/>
                </xs:choice>
                <xs:element name="Return" type="xs:boolean" />
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:simpleType name="Rule">
        <xs:restriction base ="xs:string">
            <xs:enumeration value="PaymentMethod"/>
            <xs:enumeration value="Region" />
            <xs:enumeration value="Quantity" />
            <xs:enumeration value="Schedule"/>
        </xs:restriction>
    </xs:simpleType>
    <xs:complexType name="PaymentMethodRule">
        <xs:sequence>
            <xs:element name="Accepts">
            <xs:complexType>
                    <xs:sequence>
                        <xs:element type="xs:boolean" name="Warranty"/>
                        <xs:element type="xs:boolean" name="CustomerPay"/>
                        <xs:element type="xs:boolean" name="Goodwill"/>
                        <xs:element type="xs:boolean" name="PDI"/>
                        <xs:element type="xs:boolean" name="Rectification"/>
                        <xs:element type="xs:boolean" name="ServicePlan"/>
                    </xs:sequence>
                </xs:complexType>
            </xs:element>
        </xs:sequence>
    </xs:complexType>
    <xs:complexType name="RegionRule">
        <xs:sequence>
            <xs:element name="Region">
                <xs:complexType >
                    <xs:sequence>
                        <xs:element name="NA" type="xs:boolean" />
                        <xs:element name="EU" type="xs:boolean" />
                        <xs:element name="APAC" type="xs:boolean" />
                    </xs:sequence>
                </xs:complexType>
            </xs:element>
        </xs:sequence>
    </xs:complexType>
    <xs:complexType name="QuantityRule">
        <xs:sequence>
            <xs:element name="Amount" type="xs:integer"/>
        </xs:sequence>
    </xs:complexType>
    <xs:complexType name="ScheduleRule">
        <xs:sequence>
            <xs:element name="Days">
                <xs:complexType>
                    <xs:sequence>
                        <xs:element type="xs:boolean" name="Monday"/>
                        <xs:element type="xs:boolean" name="Tuesday"/>
                        <xs:element type="xs:boolean" name="Wendsday"/>
                        <xs:element type="xs:boolean" name="Thursday"/>
                        <xs:element type="xs:boolean" name="Friday"/>
                        <xs:element type="xs:boolean" name="Saturday"/>
                        <xs:element type="xs:boolean" name="Sunday"/>                
                    </xs:sequence>
                </xs:complexType>
            </xs:element>
            <xs:element name="Period">
                <xs:complexType>
                    <xs:sequence>
                        <xs:element type="xs:time" name="From"/>
                        <xs:element type="xs:time" name="To"/>
                    </xs:sequence>
                </xs:complexType>
            </xs:element>
        </xs:sequence>
    </xs:complexType>
</xs:schema>
'