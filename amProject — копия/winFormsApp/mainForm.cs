using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace winFormsApp
{
    public partial class formMain : Form
    {
        static string connectionString;
        public formMain()
        {
            InitializeComponent();
            BuildConnectionString();
        }

        static void BuildConnectionString()
        {
            Console.WriteLine("Построение строки соединения...");
            SqlConnectionStringBuilder connectionStringBuilder = new SqlConnectionStringBuilder();

            connectionStringBuilder["Server"] = "PIF1-DB-T-01";
            connectionStringBuilder["Database"] = "fst";// "master";
            connectionStringBuilder["Trusted_Connection"] = true;
            connectionStringBuilder["Pooling"] = true;

            formMain.connectionString = connectionStringBuilder.ConnectionString;
            Console.WriteLine($"Строка подключения: {formMain.connectionString}");
        }

        static bool TestConnection()
        {
            Console.WriteLine("Тестирование соединения с БД...");
            bool connOk;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
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
                finally
                {
                    connOk = (conn.State == ConnectionState.Open);
                }
            }
            return connOk;
        }

        private void buttonExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void buttonQuery1_Click(object sender, EventArgs e)
        {
            firstForm fm = new firstForm(formMain.connectionString);
            fm.Show();
            //DbReader dbr = new DbReader(formMain.connectionString);
            //dbr.ReadData();
        }

        private void buttonCheckDBConn_Click(object sender, EventArgs e)
        {
            bool connOk = TestConnection();
            if (connOk)
            {
                Console.WriteLine($"Подключение успещно протестировано...");
            }
        }
    }
}
