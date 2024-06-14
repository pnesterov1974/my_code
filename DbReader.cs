using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace amConsoleApp1
{
    class DbRecord
    {
        public string tableName;
        public string schemaName;
        public Int64 rows;
        public Int64 totalSpaceKB;
        public Decimal totalSpaceMB;
        public Int64 usedSpaceKB;
        public Decimal usedSpaceMB;
        public Int64 unusedSpaceKB;
        public Decimal unusedSpaceMB;

        public string GetInfoString()
        {
            string str = $"{this.schemaName}.{this.tableName} => {this.rows} строк, {this.totalSpaceKB} {this.totalSpaceMB} {this.usedSpaceKB} {this.usedSpaceMB} {this.unusedSpaceKB} {this.unusedSpaceMB}";
            return str;
        }
    }

    class DbReader
    {
        private string sql = @"
SELECT 
    t.[name] AS [TableName],
    s.[name] AS [SchemaName],
    p.[rows] AS [Rows],
    SUM(a.[total_pages]) * 8 AS [TotalSpaceKB], 
    CAST(ROUND(((SUM(a.[total_pages]) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [TotalSpaceMB],
    SUM(a.[used_pages]) * 8 AS [UsedSpaceKB], 
    CAST(ROUND(((SUM(a.[used_pages]) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [UsedSpaceMB], 
    (SUM(a.[total_pages]) - SUM(a.[used_pages])) * 8 AS [UnusedSpaceKB],
    CAST(ROUND(((SUM(a.[total_pages]) - SUM(a.[used_pages])) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [UnusedSpaceMB]
FROM sys.[tables] t
INNER JOIN sys.[indexes] i ON t.[object_id] = i.[object_id]
INNER JOIN sys.[partitions] p ON (i.[object_id] = p.[object_id]) AND (i.[index_id] = p.[index_id])
INNER JOIN sys.[allocation_units] a ON p.[partition_id] = a.[container_id]
LEFT JOIN sys.[schemas] s ON t.[schema_id] = s.[schema_id]
WHERE (t.[name] NOT LIKE 'dt%') 
       AND (t.[is_ms_shipped] = 0)
       AND (i.[object_id] > 255)
       --AND (1=0)
GROUP BY t.[name], s.[name], p.[rows]
ORDER BY [TotalSpaceMB] DESC, t.[name];
";

        public List<DbRecord> Data { get; set; }

        private string connStr;
        private List<DbRecord> data;

        public DbReader(string connStr)
        {
            Console.WriteLine("Создание экземпляра...");
            this.connStr = connStr;
        }

        public void ReadData()
        {
            this.data = new List<DbRecord>();
            using (SqlConnection conn = new SqlConnection(this.connStr))
            {
                //conn.StateChange += connection_StateChange;   ???
                SqlCommand cmd = new SqlCommand(sql, conn);
                try
                {
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            while (reader.Read())
                            {
                                DbRecord dbr = new DbRecord
                                {
                                    tableName = (string)reader[0],
                                    schemaName = reader.GetString(1),
                                    rows = reader.GetInt64(2),
                                    totalSpaceKB = reader.GetInt64(3),
                                    totalSpaceMB = reader.GetDecimal(4),
                                    usedSpaceKB = reader.GetInt64(5),
                                    usedSpaceMB = reader.GetDecimal(6),
                                    unusedSpaceKB = reader.GetInt64(7),
                                    unusedSpaceMB = reader.GetDecimal(8)
                                };
                                this.data.Add(dbr);
                            }
                        }
                        else
                        {
                            Console.WriteLine("Данные отсутствуют...");
                        }
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine();
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(e.Message);
                    Console.ForegroundColor = ConsoleColor.Gray;
                }
            }
        }
    }
}
