using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace firstConsoleApp//amConsoleApp1
{
    class DbRecord
    {
        public string TableName { get; set; }
        public string SchemaName { get; set; }
        public Int64 Rows { get; set; }
        public Int64 TotalSpaceKB { get; set; }
        public Decimal TotalSpaceMB { get; set; }
        public Int64 UsedSpaceKB { get; set; }
        public Decimal UsedSpaceMB { get; set; }
        public Int64 UnusedSpaceKB { get; set; }
        public Decimal UnusedSpaceMB { get; set; }

        public string GetInfoString()
        {
            string str = $"{this.SchemaName}.{this.TableName} => {this.Rows} строк,\n{this.TotalSpaceKB} {this.TotalSpaceMB} {this.UsedSpaceKB} {this.UsedSpaceMB} {this.UnusedSpaceKB} {this.UnusedSpaceMB}";
            return str;
        }
        // Переопределение метода ToString()
        // StringBuilder
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

        public DbReader(string connStr)
        {
            Console.WriteLine("Создание экземпляра...");
            this.connStr = connStr;
        }

        private void Connection_StateChange(object sender, System.Data.StateChangeEventArgs e)
        {
            SqlConnection conn = sender as SqlConnection;
            Console.WriteLine("Изменено состояние подключения...");
            Console.WriteLine(
                    "Database: " + conn.Database + Environment.NewLine +
                    "State: " + conn.State
                );
        }


        public void ReadData()
        {
            this.Data = new List<DbRecord>();
            using (SqlConnection conn = new SqlConnection(this.connStr))
            {
                conn.StateChange += this.Connection_StateChange;
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
                                    TableName = (string)reader[0],
                                    SchemaName = reader.GetString(1),
                                    Rows = reader.GetInt64(2),
                                    TotalSpaceKB = reader.GetInt64(3),
                                    TotalSpaceMB = reader.GetDecimal(4),
                                    UsedSpaceKB = reader.GetInt64(5),
                                    UsedSpaceMB = reader.GetDecimal(6),
                                    UnusedSpaceKB = reader.GetInt64(7),
                                    UnusedSpaceMB = reader.GetDecimal(8)
                                };
                                this.Data.Add(dbr);
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
                finally {
                    Console.WriteLine($"Length od Data: {this.Data.Count} records");
                }
            }
        }
    }
}
