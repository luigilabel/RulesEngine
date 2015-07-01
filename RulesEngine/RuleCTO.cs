namespace RulesEngine
{
    public class RuleCTO
    {
        public int RuleDetailID { get; set; }

        public RuleType RuleTypeID { get; set; }

        public int RuleGroupID { get; set; }

        public string RuleConfiguration { get; set; }

        public bool IsEnabled { get; set; }
    }
}