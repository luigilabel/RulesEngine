namespace RulesEngine
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.IO;
    using System.Xml.Serialization;
    using Dapper;
    using Microsoft.SqlServer.Server;

    internal class GroupDynamicParam : Dapper.SqlMapper.IDynamicParameters
    {
        private int _userID;
        private string _profileName;
        private List<RuleGroup> _groups;

        public GroupDynamicParam(string profileName, int userID, List<RuleGroup> groups)
        {
            this._userID = userID;
            this._profileName = profileName;
            this._groups = groups;
        }

        public void AddParameters(IDbCommand command, SqlMapper.Identity identity)
        {
            var sqlCommand = (SqlCommand)command;
            sqlCommand.CommandType = CommandType.StoredProcedure;

            var groups = new List<SqlDataRecord>();
            var rules = new List<SqlDataRecord>();

            SqlMetaData[] groupSqlType =
            {
                 new SqlMetaData("GroupGuid", SqlDbType.VarChar, 32),
                 new SqlMetaData("IsSystem", SqlDbType.Bit)
            };

            SqlMetaData[] ruleSqlType =
            {
                new SqlMetaData("RuleTypeID", SqlDbType.Int),
                new SqlMetaData("GroupGuid", SqlDbType.Char, 32),
                new SqlMetaData("RuleConfiguration", SqlDbType.Xml)
            };

            foreach (RuleGroup group in this._groups)
            {
                var groupRecord = new SqlDataRecord(groupSqlType);
                string groupGuid = Guid.NewGuid().ToString().Replace("-", string.Empty);

                groupRecord.SetString(0, groupGuid);
                groupRecord.SetBoolean(1, group.IsSystem);
                groups.Add(groupRecord);

                foreach (var rule in group.Rules)
                {
                    var ruleRecord = new SqlDataRecord(ruleSqlType);
                    var ruleType = (int)rule.RuleType;
                    ruleRecord.SetInt32(0, ruleType);
                    ruleRecord.SetString(1, groupGuid);
                    ruleRecord.SetString(2, this.RuleWriter(rule));
                    rules.Add(ruleRecord);
                }
            }

            var param1 = sqlCommand.Parameters.Add("ProfileName", SqlDbType.VarChar, 50);
            param1.Value = this._profileName;

            var param2 = sqlCommand.Parameters.Add("UserID", SqlDbType.Int);
            param2.Value = this._userID;

            var param3 = sqlCommand.Parameters.Add("Groups", SqlDbType.Structured);
            param3.TypeName = "RulesGroupTableType";
            param3.Value = groups;

            var param4 = sqlCommand.Parameters.Add("Rules", SqlDbType.Structured);
            param4.TypeName = "RulesTableType";
            param4.Value = rules;
        }

        public string RuleWriter(Rule rule)
        {
            StringWriter writer = new StringWriter();
            XmlSerializer ruleSerializer = null;
            switch (rule.RuleType)
            {
                case RuleType.PaymentMethod:
                    ruleSerializer = new XmlSerializer(typeof(PayMethodRule));
                    break;

                case RuleType.Region:
                    ruleSerializer = new XmlSerializer(typeof(RegionRule));
                    break;

                case RuleType.QuantityNeeded:
                    ruleSerializer = new XmlSerializer(typeof(QuantityNeededRule));
                    break;

                case RuleType.Schedule:
                    ruleSerializer = new XmlSerializer(typeof(ScheduleRule));
                    break;
            }

            var xmlnsEmpty = new XmlSerializerNamespaces();
            xmlnsEmpty.Add(string.Empty, string.Empty);
            ruleSerializer.Serialize(writer, rule, xmlnsEmpty);
            return writer.ToString();
        }
    }
}