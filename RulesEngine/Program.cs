namespace RulesEngine
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using System.Xml.Serialization;
    using Dapper;

    public class Program
    {
        public static IDbConnection Connection
        {
            get
            {
                return new SqlConnection(Properties.Settings.Default.ConnectionString);
            }
        }

        public static IEnumerable<RuleProfile> FindAllProfiles()
        {
            IEnumerable<RuleProfile> profiles = new List<RuleProfile>();
            using (IDbConnection cn = Connection)
            {
                cn.Open();
                profiles = cn.Query<RuleProfile>("select profileid as ID, Name  from rulesprofile");
                cn.Close();
            }

            return profiles;
        }

        public static void InsertProfile(RuleProfile profile, int userID)
        {
            using (IDbConnection cn = Connection)
            {
                cn.Open();
                cn.Execute(
                    "CreateProfile",
                    new GroupDynamicParam(userID, profile.ID, profile.Name, profile.Groups.AsList()),
                    commandType: CommandType.StoredProcedure,
                    commandTimeout: 120);
                cn.Close();
            }
        }

        public static void DeleteProfile(RuleProfile profile, int userID)
        {
            using (IDbConnection cn = Connection)
            {
                cn.Open();
                int done = cn.Execute(
                    "DeleteProfile",
                    new { ProfileID = profile.ID, UserID = userID },
                    commandType: CommandType.StoredProcedure);
                cn.Close();
            }
        }

        public static void UpdateProfile(RuleProfile profile, int userID)
        {
            using (IDbConnection cn = Connection)
            {
                cn.Open();
                int done = cn.Execute(
                "UpdateProfile",
                new GroupDynamicParam(userID, profile.ID, profile.Name, profile.Groups.AsList()),
                commandType: CommandType.StoredProcedure);
                cn.Close();
            }
        }

        public static RuleProfile ReadProfile(int profileID)
        {
            var profile = new List<RuleProfile>();
            using (IDbConnection cn = Connection)
            {
                cn.Open();
                var multi = cn.QueryMultiple(
                    "ReadProfile",
                    new { ProfileID = profileID },
                    commandTimeout: 120,
                    commandType: CommandType.StoredProcedure);
                profile = multi.Read<RuleProfile>().ToList();
                var groups = multi.Read<RuleGroup>().AsList();
                var rulesCTO = multi.Read<RuleCTO>().AsList();
                cn.Close();
                var ruleList = new List<Rule>();
                foreach (var rule in rulesCTO)
                {
                    var tempRule = new Rule();
                    switch (rule.RuleTypeID)
                    {
                        case RuleType.PaymentMethod:
                            tempRule = Deserialize<PaymentMethodRule>(rule.RuleConfiguration);
                            break;

                        case RuleType.QuantityNeeded:
                            tempRule = Deserialize<QuantityNeededRule>(rule.RuleConfiguration);
                            break;

                        case RuleType.Region:
                            tempRule = Deserialize<RegionRule>(rule.RuleConfiguration);
                            break;

                        case RuleType.Schedule:
                            tempRule = Deserialize<ScheduleRule>(rule.RuleConfiguration);
                            break;
                    }

                    tempRule.ID = rule.ID;
                    tempRule.GroupID = rule.RuleGroupID;
                    tempRule.IsEnabled = rule.IsEnabled;
                    ruleList.Add(tempRule);
                }

                foreach (var group in groups)
                {
                    var groupRuleList = ruleList.Where(r => r.GroupID == group.ID);
                    group.Rules = groupRuleList;
                }

                profile.First().Groups = groups;
            }

            return profile.First();
        }

        public static string Serialize<T>(T value)
        {
            if (value == null)
            {
                return null;
            }

            XmlSerializer serializer = new XmlSerializer(typeof(T));

            XmlWriterSettings settings = new XmlWriterSettings();
            settings.Encoding = new UnicodeEncoding(false, false); // no BOM in a .NET string
            settings.Indent = false;
            settings.OmitXmlDeclaration = false;

            using (StringWriter textWriter = new StringWriter())
            {
                using (XmlWriter xmlWriter = XmlWriter.Create(textWriter, settings))
                {
                    serializer.Serialize(xmlWriter, value);
                }

                return textWriter.ToString();
            }
        }

        public static T Deserialize<T>(string xml)
        {
            if (string.IsNullOrEmpty(xml))
            {
                return default(T);
            }

            XmlSerializer serializer = new XmlSerializer(typeof(T));

            XmlReaderSettings settings = new XmlReaderSettings();

            using (StringReader textReader = new StringReader(xml))
            {
                using (XmlReader xmlReader = XmlReader.Create(textReader, settings))
                {
                    return (T)serializer.Deserialize(xmlReader);
                }
            }
        }

        private static void Main(string[] args)
        {
            var rule1 = new PaymentMethodRule
            {
                PaymentMethods = new List<PaymentMethod>()
                {
                    PaymentMethod.Warranty, PaymentMethod.Rectification
                },
                IsReturnable = true,
                IsEnabled = true
            };

            var rule2 = new RegionRule
            {
                Regions = new List<Region>()
                {
                    Region.NA, Region.EU
                },
                IsReturnable = true
            };

            var rule3 = new QuantityNeededRule
            {
                Amount = 10,
                IsReturnable = true,
                IsEnabled = true
            };

            var rule4 = new ScheduleRule
            {
                Days = new List<DayOfWeek>()
                {
                    DayOfWeek.Monday,
                    DayOfWeek.Tuesday,
                    DayOfWeek.Wednesday,
                    DayOfWeek.Thursday,
                    DayOfWeek.Friday,
                    DayOfWeek.Saturday,
                    DayOfWeek.Sunday
                },

                From = new TimeSpan(2, 30, 00),
                To = new TimeSpan(4, 30, 00),
                IsReturnable = true,
                IsEnabled = true
            };

            var group1 = new RuleGroup
            {
                Rules = new List<Rule>() { rule1, rule2 },
                IsSystem = false,
                IsEnabled = true,
                DisplayOrder = 0
            };

            var group2 = new RuleGroup
            {
                Rules = new List<Rule>() { rule3, rule4 },
                IsSystem = false,
                IsEnabled = true,
                DisplayOrder = 1
            };

            var profile1 = new RuleProfile
            {
                Name = "Perfil1 Test",
                Groups = new List<RuleGroup>() { group1, group2 },
            };
            var profile2 = new RuleProfile
            {
                ID = 1025
            };

            InsertProfile(profile1, 1);
            ////profile1 = ReadProfile(1024);
            profile1.Name = "Refreshed";
            var rule5 = new QuantityNeededRule
            {
                GroupID = 38487,
                Amount = 10,
                IsReturnable = true,
                IsEnabled = true
            };
            rule3.IsEnabled = false;
            profile1.Groups.First().Rules = profile1.Groups.First().Rules.Concat<Rule>(new List<Rule> { rule5 });
            ////UpdateProfile(profile1, 2);
            ////DeleteProfile(profile2, 1);
        }
    }
}