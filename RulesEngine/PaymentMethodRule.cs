namespace RulesEngine
{
    using System.Collections.Generic;
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

    [XmlRoot("Rule")]
    public class PaymentMethodRule : Rule
    {
        public PaymentMethodRule()
        {
            this.RuleTypeID = RuleType.PaymentMethod;
        }

        [XmlArray("PaymentConfiguration")]
        public List<PaymentMethod> PaymentMethods { get; set; }
    }
}