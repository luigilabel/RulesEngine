namespace RulesEngine
{
    using System.Collections.Generic;

    public class RuleProfile
    {
        public int RuleProfileID { get; set; }

        public string Name { get; set; }

        public IEnumerable<RuleGroup> Groups { get; set; }
    }
}