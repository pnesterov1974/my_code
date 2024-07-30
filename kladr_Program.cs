using Shared;
using mssqlDb;

Console.WriteLine("Hello, World!");

string connStr = "Data Source=;Initial Catalog=kladr;Integrated Security=True;Pooling=True;Trust Server Certificate=True;Connection Timeout=500";

MsSqlDbObjectOption socrbaseOptions = new MsSqlDbObjectOption()
{
    ConnectionString = connStr,
    Sql = """
        SELECT [LEVEL],
               [SCNAME],
               [SOCRNAME],
               [KOD_T_ST]
        FROM dbo.[SOCRBASE];
        """,
    FilenameSubstring = "socrbase"
};
KladrData sb = new KladrData(oi: socrbaseOptions);
sb.SaveJsonSchema();
sb.SaveJsonData();

MsSqlDbObjectOption altnamesOptions = new MsSqlDbObjectOption()
{
    ConnectionString = connStr,
    Sql = """
        SELECT [LEVEL],
               [OLDCODE],
               [NEWCODE]
        FROM dbo.[ALTNAMES];
        """,
    FilenameSubstring = "altnames"
};
KladrData an = new KladrData(oi: altnamesOptions);
an.SaveJsonSchema();
an.SaveJsonData();

MsSqlDbObjectOption kladrOptions = new MsSqlDbObjectOption()
{
    ConnectionString = connStr,
    Sql = """
        SELECT [CODE],
               [NAME],
               [SOCR],
               [INDEX],
               [GNINMB],
               [UNO],
               [OCATD],
               [STATUS]
        FROM dbo.[KLADR];
        """,
    FilenameSubstring = "kladr"
};
KladrData kl = new KladrData(oi: kladrOptions);
kl.SaveJsonSchema();
kl.SaveJsonData();

MsSqlDbObjectOption streetOptions = new MsSqlDbObjectOption()
{
    ConnectionString = connStr,
    Sql = """
        SELECT [CODE],
               [NAME],
               [SOCR],
               [INDEX],
               [GNINMB],
               [UNO],
               [OCATD]
        FROM dbo.[STREET];
        """,
    FilenameSubstring = "street"
};
KladrData st = new KladrData(oi: streetOptions);
st.SaveJsonSchema();
st.SaveJsonData();

MsSqlDbObjectOption domaOptions = new MsSqlDbObjectOption()
{
    ConnectionString = connStr,
    Sql = """
        SELECT [CODE],
               [NAME],
               [KORP],
               [SOCR],
               [INDEX],
               [GNINMB],
               [UNO],
               [OCATD]
        FROM dbo.[DOMA];
        """,
    FilenameSubstring = "doma"
};
KladrData dm = new KladrData(oi: domaOptions);
dm.SaveJsonSchema();
dm.SaveJsonData();

