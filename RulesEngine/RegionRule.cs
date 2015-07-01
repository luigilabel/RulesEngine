namespace RulesEngine
{
    using System.Collections.Generic;
    using System.Xml.Serialization;

    public enum Region
    {
        NA,
        EU,
        APAC
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
}