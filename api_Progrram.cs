using adodb;

var MyAllowSpecificOrigins = "_AllowAllSpecificOrigins";

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: MyAllowSpecificOrigins, policy => policy.WithOrigins("*")
            .AllowAnyHeader()
            .AllowAnyMethod());
});

var app = builder.Build();

app.UseCors(MyAllowSpecificOrigins);

var config = new ConfigurationBuilder()
                 .AddJsonFile("appsettings.json")
                 .SetBasePath(Directory.GetCurrentDirectory())
                 .Build();
string connStr = config.GetConnectionString("DefaultConnection");

app.MapGet("/socrbase", () =>
{
    SocrBaseReader sbr = new SocrBaseReader(connStr);
    return sbr.DataAsJson;
});

app.MapGet("/altnames", () =>
{
    AltNamesReader alr = new AltNamesReader(connStr);
    return alr.DataAsJson;
});

app.MapGet("/kladr", () =>
{
    KladrReader klr = new KladrReader(connStr);
    return klr.DataAsJson;
});

app.MapGet("/street", () =>
{
    StreetReader str = new StreetReader(connStr);
    return str.DataAsJson;
});

app.MapGet("/doma", () =>
{
    DomaReader dmr = new DomaReader(connStr);
    return dmr.DataAsJson;
});

app.MapGet("/kladr_actual", () =>
{
     KladrActualReader klar = new KladrActualReader(connStr);
     return klar.DataAsJson;
});
// TODO: street_actual - целиком слишком большой json
app.MapGet("/street_actual", () =>
{
     StreetActualReader star = new StreetActualReader(connStr);
     return star.DataAsJson;
});

// app.MapGet("/shirts/{id}",(int id) => {
//     return $"Reading shirt with ID: {id}"
// })

app.Run();
