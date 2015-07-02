namespace RulesEngine
{
    using System.Collections.Generic;

    public class RuleGroup
    {
        public int ID { get; set; }
        
        public int RuleProfileID { get; set; }
         
        public bool IsSystem { get; set; }

        public int DisplayOrder { get; set; }

        public bool IsEnabled { get; set; }

        public IEnumerable<Rule> Rules { get; set; }
    }
}