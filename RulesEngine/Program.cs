namespace RulesEngine
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using Dapper;

    internal class Program
    {
        internal static IDbConnection Connection
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
                    new GroupDynamicParam(profile.Name, userID, profile.Groups.AsList()),
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

        private static void Main(string[] args)
        {
            var rule1 = new PayMethodRule
            {
                PaymentMethods = new List<PaymentMethod>()
                {
                    PaymentMethod.Warranty, PaymentMethod.Rectification
                },
                IsReturnable = true
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
                IsReturnable = true
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
                IsReturnable = true
            };

            var group1 = new RuleGroup
            {
                Description = "rule1 and rule2",
                Rules = new List<Rule>() { rule1, rule2 },
                IsSystem = false
            };

            var group2 = new RuleGroup
            {
                Description = "rule3 and rule4",
                Rules = new List<Rule>() { rule3, rule4 },
                IsSystem = false
            };

            var profile1 = new RuleProfile
            {
                Name = "Perfil1 Test",
                Groups = new List<RuleGroup>() { group1, group2 },
            };
            var profile2 = new RuleProfile
            {
                ID = 42
            };

            InsertProfile(profile1, 1);
            DeleteProfile(profile2, 1);
        }
    }
}