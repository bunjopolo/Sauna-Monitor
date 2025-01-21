using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using SaunaMonitor;
using SaunaMonitor.Data;
using SaunaMonitor.Models;
using SaunaMonitor.Services;


var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<MeasurementDb>(opt => opt.UseSqlite("Data Source=sauna.db"));

var webSocketHandler = new WebSocketHandler();
builder.Services.AddSingleton<WebSocketHandler>();
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

var app = builder.Build();

// GET /measurements
app.MapGet("/measurements", async (MeasurementDb db) =>
{
    var measurements = await db.Measurements
        .OrderByDescending(m => m.ReadingDate)
        .ToListAsync();
    
    return Results.Ok(measurements);
});


// Deletes all measurements from the database (development only to clear test values)
app.MapDelete("/measurements", async (MeasurementDb db) =>
{
    try
    {
        db.Measurements.RemoveRange(db.Measurements);
        await db.SaveChangesAsync();
        return Results.Ok("All measurements deleted");
    }
    catch (Exception e)
    {
        return Results.Problem($"Error occurred while deleting entries: {e.Message}");
    }
});



// POST /measurements
app.MapPost("/measurements", async (Measurement measurement, MeasurementDb db) =>
{
    Console.WriteLine("Incoming Data:");
    Console.WriteLine($"TemperatureC: {measurement?.TemperatureC}");
    Console.WriteLine($"Humidity: {measurement?.Humidity}");
    Console.WriteLine($"ReadingDate: {measurement?.ReadingDate}");

    if (measurement == null) return Results.BadRequest("Invalid data.");

    db.Measurements.Add(measurement);
    await db.SaveChangesAsync();

    return Results.Created($"/measurements/{measurement.Id}", measurement);
});

// POST /webhook
app.MapPost("/webhook", async (HttpRequest request, MeasurementDb db) =>
{
    // Read the incoming request body
    var requestBody = await new StreamReader(request.Body).ReadToEndAsync();

    // Deserialize the request body into a dynamic object
    var payload = JsonSerializer.Deserialize<JsonElement>(requestBody);

    // Deserialize the "data" field into the SensorData object
    var sensorData = JsonSerializer.Deserialize<JsonElement>(payload.GetProperty("data").GetString());


    // Create a new Measurement object
    var measurement = new Measurement
    {
        TemperatureC = sensorData.GetProperty("temperatureC").GetDouble(),
        Humidity = sensorData.GetProperty("humidity").GetSingle(),
        ReadingDate = DateTime.UtcNow.ToLocalTime()
    };

    //Save the measurement to the database
    db.Measurements.Add(measurement);
    await db.SaveChangesAsync();
    
    var message = JsonSerializer.Serialize(measurement);
    await webSocketHandler.BroadcastMessage(message);
    
    return Results.Created($"/measurements/{measurement.Id}", measurement);
});

// GET /ws
app.MapGet("/ws", async (HttpContext context) =>
{
    if (context.WebSockets.IsWebSocketRequest)
    {
        var webSocket = await context.WebSockets.AcceptWebSocketAsync();
        await webSocketHandler.HandleWebSocketConnection(context, webSocket);
    }
    else
    {
        context.Response.StatusCode = 400;
    }
    

});



app.Run();