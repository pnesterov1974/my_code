using System;
using System.Data;
using System.Data.SqlClient;
// 
namespace firstConsoleApp
{
    class Program
    {
        static string connectionString;// = $"Server=PIF1-DB-T-01;Database=master;Trusted_Connection=True;";
        static void Main(string[] args)
        {
            Console.WriteLine(new string('-', 20));
            buildConnectionString();
            Console.WriteLine(new string('-', 20));
            testConnection();
            Console.WriteLine(new string('-', 20));
            runScalarCommand();
            Console.WriteLine(new string('-', 20));
            runDataCommand();
        }

        static void connection_StateChange(object sender, System.Data.StateChangeEventArgs e)
        {
            SqlConnection conn = sender as SqlConnection;
            Console.WriteLine("Изменено состояние подключения...");
            Console.WriteLine(
                    //"Data source: " + conn.DataSource + Environment.NewLine +
                    "Database: " + conn.Database + Environment.NewLine +
                    "State: " + conn.State
                );
        }

        static void testConnection()
        {
            Console.WriteLine("Тестирование соединения с БД...");
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.StateChange += connection_StateChange;

                try
                {
                    conn.Open();
                    Console.WriteLine("Свойства подключения:");
                    Console.WriteLine($"\tСтрока подключения: {conn.ConnectionString}");
                    Console.WriteLine($"\tБаза данных: {conn.Database}");
                    Console.WriteLine($"\tСервер: {conn.DataSource}");
                    Console.WriteLine($"\tВерсия сервера: {conn.ServerVersion}");
                    Console.WriteLine($"\tСостояние: {conn.State}");
                    Console.WriteLine($"\tWorkstationId: {conn.WorkstationId}");
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

        static void buildConnectionString()
        {
            Console.WriteLine("Построение строки соединения...");
            SqlConnectionStringBuilder connectionStringBuilder = new SqlConnectionStringBuilder();

            connectionStringBuilder["Server"] = "PIF1-DB-T-01";
            connectionStringBuilder["Database"] = "fst";// "master";
            connectionStringBuilder["Trusted_Connection"] = true;
            connectionStringBuilder["Pooling"] = true;

            Program.connectionString = connectionStringBuilder.ConnectionString;
            Console.WriteLine($"Строка подключения: {Program.connectionString}");
        }

        static void runScalarCommand()
        {
            Console.WriteLine("Запрос на скалярное значение...");
            string commandSQL = @"SELECT GETDATE();";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.StateChange += connection_StateChange;
                SqlCommand cmd = new SqlCommand(commandSQL, conn);
                try
                {
                    conn.Open();
                    DateTime dttm = (DateTime)cmd.ExecuteScalar();
                    Console.WriteLine(dttm.ToString());
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

        static void runDataCommand()
        {
            Console.WriteLine("Звпрос на выюорку из БД...");
            string commandSQL = @"
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

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.StateChange += connection_StateChange;
                SqlCommand cmd = new SqlCommand(commandSQL, conn);
                try
                {
                    conn.Open();
                   
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows) {
                            while (reader.Read())
                            {
                                var tableNameType = reader[0].GetType();
                                var tableNameInDB = reader[0].ToString();
                                //Console.WriteLine($"Тип для {tableNameInDB}: {tableNameType.ToString()}");
                                string tableName = (string)reader[0];

                                var schemaNameType = reader[1].GetType();
                                var schemaNameInDB = reader[1].ToString();
                                //Console.WriteLine($"Тип для {schemaNameInDB}: {schemaNameType.ToString()}");
                                string schemaName = reader.GetString(1);

                                var rowsType = reader[2].GetType();
                                var rowsNameInDB = reader[2].ToString();
                                //Console.WriteLine($"Тип для {rowsNameInDB}: {rowsType.ToString()}");
                                Int64 rows = reader.GetInt64(2);

                                var totalSpaceKBType = reader[3].GetType();
                                var totalSpaceKBInDB = reader[3].ToString();
                                //Console.WriteLine($"Тип для {totalSpaceKBInDB}: {totalSpaceKBType.ToString()}");
                                Int64 totalSpaceKB = reader.GetInt64(3);

                                var totalSpaceMBType = reader[4].GetType();
                                var totalSpaceMBInDB = reader[4].ToString();
                                //Console.WriteLine($"Тип для {totalSpaceMBInDB}: {totalSpaceMBType.ToString()}");
                                Decimal totalSpaceMB = reader.GetDecimal(4);

                                var usedSpaceKBType = reader[5].GetType();
                                var usedSpaceKBInDB = reader[5].ToString();
                                //Console.WriteLine($"Тип для {usedSpaceKBInDB}: {usedSpaceKBType.ToString()}");
                                Int64 usedSpaceKB = reader.GetInt64(5);

                                var usedSpaceMBType = reader[6].GetType();
                                var usedSpaceMBInDB = reader[6].ToString();
                                //Console.WriteLine($"Тип для {usedSpaceMBInDB}: {usedSpaceMBType.ToString()}");
                                Decimal usedSpaceMB = reader.GetDecimal(6);

                                var unusedSpaceKBType = reader[7].GetType();
                                var unusedSpaceKBInDB = reader[7].ToString();
                                //Console.WriteLine($"Тип для {unusedSpaceKBInDB}: {unusedSpaceKBType.ToString()}");
                                Int64 unusedSpaceKB = reader.GetInt64(7);

                                var unusedSpaceMBType = reader[8].GetType();
                                var unusedSpaceMBInDB = reader[8].ToString();
                                //Console.WriteLine($"Тип для {unusedSpaceMBInDB}: {unusedSpaceMBType.ToString()}");
                                Decimal unusedSpaceMB = reader.GetDecimal(8);

                                //Console.WriteLine(tableName + " " + schemaName + " " + rows + " " + totalSpaceKB);
                                string str = $"{schemaName}.{tableName} => {rows} строк, {totalSpaceKB} {totalSpaceMB} {usedSpaceKB} {usedSpaceMB} {unusedSpaceKB} {unusedSpaceMB}";
                                Console.WriteLine(str);
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
