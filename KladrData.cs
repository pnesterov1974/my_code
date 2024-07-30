using System.Data;
using Microsoft.Data.SqlClient;
using Newtonsoft.Json;
using Shared;

namespace mssqlDb;

public class KladrData
{
    public KladrData(string connectionString, string sql, string filenameSubString)
    {
        this.connectionString = connectionString;
        this.sql = sql;
        this.filenameSubstring = filenameSubString;
    }

    public KladrData(MsSqlDbObjectOption oi)
    {
        this.connectionString = oi.ConnectionString;
        this.sql = oi.Sql;
        this.filenameSubstring = oi.FilenameSubstring;
    }

    protected string connectionString { get; set; } = string.Empty;

    protected DataSet Data { get; set; }
    protected DataTable TableData
    {
        get
        {
            return this.Data.Tables[0];
        }
    }
    protected DataTable TableSchema { get; set; }

    protected string sql = string.Empty;
    protected string filenameSubstring = string.Empty;
    public string SchemaAsJson
    {
        get
        {
            this.ReadSchema();
            return JsonConvert.SerializeObject(this.TableSchema, Formatting.Indented);
        }
    }
    public string DataAsJson
    {
        get
        {
            this.ReadData();
            return JsonConvert.SerializeObject(this.TableData, Formatting.Indented);
        }
    }

    protected void Connection_StateChange(object sender, System.Data.StateChangeEventArgs e)
    {
        SqlConnection? conn = sender as SqlConnection;
        Console.Write("Изменено состояние подключения...\t");
        Console.Write("Database: " + conn.Database + "\tState: " + conn.State);
        Console.WriteLine();
    }

    protected void ReadSchema()
    {
        this.TableSchema = new DataTable();
        using (SqlConnection conn = new SqlConnection(this.connectionString))
        {
            conn.StateChange += this.Connection_StateChange;
            using (SqlCommand cmd = new SqlCommand(this.sql, conn))
            {
                conn.Open();
                using (SqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.KeyInfo))
                {
                    this.TableSchema = rdr.GetSchemaTable();
                }
                conn.Close();
            }
        }
    }

    protected void ReadData()
    {
        this.Data = new DataSet();
        using (SqlConnection conn = new SqlConnection(this.connectionString))
        {
            conn.StateChange += this.Connection_StateChange;
            SqlDataAdapter adapter = new SqlDataAdapter(this.sql, conn);
            try
            {
                adapter.Fill(this.Data);
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
                Console.WriteLine($"Объект {this.filenameSubstring}, загружено {this.TableData.Rows.Count} записей");
            }
        }
    }

    public void SaveJsonSchema()
    {
        string schemaJsonFilePath = Directory.GetCurrentDirectory() + $"\\{this.filenameSubstring}_schema.json";
        File.WriteAllText(schemaJsonFilePath, this.SchemaAsJson);
    }

    public void SaveJsonData()
    {
        string dataJsonFilePath = Directory.GetCurrentDirectory() + $"\\{this.filenameSubstring}.json";
        File.WriteAllText(dataJsonFilePath, this.DataAsJson);
    }
}
