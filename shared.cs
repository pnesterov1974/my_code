namespace Shared;

public struct MsSqlDbObjectOption
{
    public string ConnectionString;
    public string Sql;
    public string FilenameSubstring;
}

public enum TargetTable
{
    SocrBase,
    AltNames,
    Kladr,
    Streets,
    Doma
}
