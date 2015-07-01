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
        private int _profileID;
        private string _profileName;
        private List<RuleGroup> _groups;

        public GroupDynamicParam(int userID, int profileID, string profileName, List<RuleGroup> groups)
        {
            this._userID = userID;
            this._profileID = profileID;
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
                new SqlMetaData("RuleGroupID", SqlDbType.Int),
                new SqlMetaData("GroupGuid", SqlDbType.VarChar, 32),
                new SqlMetaData("IsSystem", SqlDbType.Bit),
                new SqlMetaData("DisplayOrder", SqlDbType.Int),
                new SqlMetaData("[IsEnabled]", SqlDbType.Bit)
            };

            SqlMetaData[] ruleSqlType =
            {
                new SqlMetaData("RuleDetailID", SqlDbType.Int),
                new SqlMetaData("RuleTypeID", SqlDbType.Int),
                new SqlMetaData("GroupGuid", SqlDbType.Char, 32),
                new SqlMetaData("RuleConfiguration", SqlDbType.Xml),
                new SqlMetaData("[IsEnabled]", SqlDbType.Bit)
            };

            foreach (RuleGroup group in this._groups)
            {
                var groupRecord = new SqlDataRecord(groupSqlType);
                string groupGuid = Guid.NewGuid().ToString().Replace("-", string.Empty);

                groupRecord.SetInt32(0, group.RuleGroupID);
                groupRecord.SetString(1, groupGuid);
                groupRecord.SetBoolean(2, group.IsSystem);
                groupRecord.SetInt32(3, group.DisplayOrder);
                groupRecord.SetBoolean(4, group.IsEnabled);
                groups.Add(groupRecord);

                foreach (var rule in group.Rules)
                {
                    var ruleRecord = new SqlDataRecord(ruleSqlType);
                    var ruleType = (int)rule.RuleType;

                    ruleRecord.SetInt32(0, rule.ID);
                    ruleRecord.SetInt32(1, ruleType);
                    ruleRecord.SetString(2, groupGuid);
                    ruleRecord.SetString(3, this.RuleWriter(rule));
                    ruleRecord.SetSqlBoolean(4, rule.IsEnabled);
                    rules.Add(ruleRecord);
                }
            }

            var userIDParam = sqlCommand.Parameters.Add("UserID", SqlDbType.Int);
            userIDParam.Value = this._userID;

            var profileIDParam = sqlCommand.Parameters.Add("ProFileID", SqlDbType.Int);
            profileIDParam.Value = this._profileID;

            var profileNameParam = sqlCommand.Parameters.Add("ProfileName", SqlDbType.VarChar, 50);
            profileNameParam.Value = this._profileName;

            var groupsPAram = sqlCommand.Parameters.Add("Groups", SqlDbType.Structured);
            groupsPAram.TypeName = "RulesGroupTableType";
            groupsPAram.Value = groups;

            var rulesParam = sqlCommand.Parameters.Add("Rules", SqlDbType.Structured);
            rulesParam.TypeName = "RulesTableType";
            rulesParam.Value = rules;
        }

        public string RuleWriter(Rule rule)
        {
            StringWriter writer = new StringWriter();
            XmlSerializer ruleSerializer = null;
            switch (rule.RuleType)
            {
                case RuleType.PaymentMethod:
                    ruleSerializer = new XmlSerializer(typeof(PaymentMethodRule));
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