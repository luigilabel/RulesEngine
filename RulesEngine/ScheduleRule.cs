namespace RulesEngine
{
    using System;
    using System.Collections.Generic;
    using System.Xml.Serialization;

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
}