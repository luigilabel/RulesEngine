namespace RulesEngine
{
    using System.Xml.Serialization;

    public enum RuleType
    {
        PaymentMethod = 1,
        Region,
        QuantityNeeded,
        Schedule
    }

    public class Rule
    {
        [XmlIgnore]
        public int ID { get; set; }

        [XmlElement("Type")]
        public RuleType RuleTypeID { get; set; }

        [XmlIgnore]
        public int GroupID { get; set; }

        [XmlElement("Return")]
        public bool IsReturnable { get; set; }

        [XmlIgnore]
        public bool IsEnabled { get; set; }
    }
}