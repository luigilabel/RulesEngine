namespace RulesEngine
{
    using System;
    using System.Collections.Generic;
    using System.Xml;
    using System.Xml.Serialization;

    public enum PaymentMethod
    {
        Warranty,
        CustomerPay,
        Goodwill,
        PDI,
        Rectification,
        ServicePlan
    }

    public enum Region
    {
        NA,
        EU,
        APAC
    }

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
        public RuleType RuleType { get; set; }

        [XmlIgnore]
        public int GroupID { get; set; }

        [XmlElement("Return")]
        public bool IsReturnable { get; set; }
    }

    [XmlRoot("Rule")]
    public class PayMethodRule : Rule
    {
        public PayMethodRule()
        {
            this.RuleType = RuleType.PaymentMethod;
        }

        [XmlArray("PaymentConfiguration")]
        public List<PaymentMethod> PaymentMethods { get; set; }
    }

    [XmlRoot("Rule")]
    public class QuantityNeededRule : Rule
    {
        public QuantityNeededRule()
        {
            this.RuleType = RuleType.QuantityNeeded;
        }

        [XmlElement("QuantityConfiguration")]
        public int Amount { get; set; }
    }

    [XmlRoot("Rule")]
    public class RegionRule : Rule
    {
        public RegionRule()
        {
            this.RuleType = RuleType.Region;
        }

        [XmlArray("RegionConfiguration")]
        public List<Region> Regions { get; set; }
    }

    [XmlRoot("Rule")]
    public class ScheduleRule : Rule
    {
        public ScheduleRule()
        {
            this.RuleType = RuleType.Schedule;
        }

        [XmlArray("ScheduleConfiguration")]
        [XmlArrayItem("Day")]
        public List<DayOfWeek> Days { get; set; }

        [XmlIgnore]
        public TimeSpan From { get; set; }

        [XmlElement("From")]
        public string Mybegining
        {
            get { return this.From.ToString(); }
            set { this.From = TimeSpan.Parse(value); }
        }

        [XmlIgnore]
        public TimeSpan To { get; set; }

        [XmlElement("To")]
        public string MyEnding
        {
            get { return this.To.ToString(); }
            set { this.To = TimeSpan.Parse(value); }
        }
    }

    public class RuleGroup
    {
        public int ProfileID { get; set; }

        public int ID { get; set; }

        public bool IsSystem { get; set; }

        public string Description { get; set; }

        public IEnumerable<Rule> Rules { get; set; }
    }

    public class RuleProfile
    {
        public int ID { get; set; }

        public string Name { get; set; }

        public IEnumerable<RuleGroup> Groups { get; set; }
    }
}