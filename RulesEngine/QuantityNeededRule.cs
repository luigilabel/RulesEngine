namespace RulesEngine
{
    using System.Xml.Serialization;

    [XmlRoot("Rule")]
    public class QuantityNeededRule : Rule
    {
        public QuantityNeededRule()
        {
            this.RuleType = RuleType.QuantityNeeded;
        }

        [XmlElement("Quantity")]
        public int Amount { get; set; }
    }
}