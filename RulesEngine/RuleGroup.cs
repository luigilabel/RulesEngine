namespace RulesEngine
{
    using System.Collections.Generic;

    public class RuleGroup
    {
        public int RuleProfileID { get; set; }

        public int RuleGroupID { get; set; }

        public bool IsSystem { get; set; }

        public int DisplayOrder { get; set; }

        public IEnumerable<Rule> Rules { get; set; }

        public bool IsEnabled { get; set; }
    }
}