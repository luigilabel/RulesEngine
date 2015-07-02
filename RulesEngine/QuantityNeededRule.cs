namespace RulesEngine
{
    using System.Xml.Serialization;

    [XmlRoot("Rule")]
    public class QuantityNeededRule : Rule
    {
        public QuantityNeededRule()
        {
            this.RuleTypeID = RuleType.QuantityNeeded;
        }

        [XmlElement("Quantity")]
        public int Amount { get; set; }
    }
}