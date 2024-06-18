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
            BuildConnectionString();
            Console.WriteLine(new string('-', 20));
            TestConnection();
            Console.WriteLine(new string('-', 20));
            RunScalarCommand();
            Console.WriteLine(new string('-', 20));
            RunDataCommand();
        }

        static void Connection_StateChange(object sender, System.Data.StateChangeEventArgs e)
        {
            SqlConnection conn = sender as SqlConnection;
            Console.WriteLine("Изменено состояние подключения...");
            Console.WriteLine(
                    //"Data source: " + conn.DataSource + Environment.NewLine +
                    "Database: " + conn.Database + Environment.NewLine +
                    "State: " + conn.State
                );
        }

        static void TestConnection()
        {
            Console.WriteLine("Тестирование соединения с БД...");
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.StateChange += Connection_StateChange;

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

        static void BuildConnectionString()
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

        static void RunScalarCommand()
        {
            Console.WriteLine("Запрос на скалярное значение...");
            string commandSQL = @"SELECT GETDATE();";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.StateChange += Connection_StateChange;
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

        static void RunDataCommand()
        {
            DbReader dbr = new DbReader(connectionString);
            dbr.ReadData();
        }
    }
}
