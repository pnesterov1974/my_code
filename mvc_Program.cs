using adodb;

var MyAllowSpecificOrigins = "_AllowAllSpecificOrigins";

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: MyAllowSpecificOrigins, policy => policy.WithOrigins("*")
            .AllowAnyHeader()
            .AllowAnyMethod());
});
builder.Services.AddControllers();
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(MyAllowSpecificOrigins);
//app.UseHttpsRedirection();
app.MapControllers();

app.Run();
