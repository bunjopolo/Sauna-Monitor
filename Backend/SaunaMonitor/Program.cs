using SaunaMonitor.Models;
using SaunaMonitor.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query;

//test comment

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<MeasurementDb>(opt => opt.UseSqlite("Data Source=sauna.db"));

builder.Services.AddDatabaseDeveloperPageExceptionFilter();
var app = builder.Build();

app.MapGet("/measurements", async (MeasurementDb db) =>
{
    var measurements = await db.Measurements
        .OrderByDescending(m => m.ReadingDate)
        .ToListAsync();

    var mostRecent = measurements.FirstOrDefault();

    return Results.Ok(measurements);
});

app.MapPost("/measurements", async (Measurement measurement, MeasurementDb db) =>
{
    
    Console.WriteLine("Incoming Data:");
    Console.WriteLine($"TemperatureC: {measurement?.TemperatureC}");
    Console.WriteLine($"Humidity: {measurement?.Humidity}");
    Console.WriteLine($"ReadingDate: {measurement?.ReadingDate}");

    if (measurement == null)
    {
        return Results.BadRequest("Invalid data.");
    }
    
    db.Measurements.Add(measurement);
    await db.SaveChangesAsync();

    return Results.Created($"/measurements/{measurement.Id}", measurement);
});

app.MapPost("/webhook", async (Measurement measurement, MeasurementDb db) =>
{
    
    // Get the current UTC time
    DateTime utcNow = DateTime.UtcNow;

    // Convert the UTC time to the local time zone, considering daylight saving time
    TimeZoneInfo localTimeZone = TimeZoneInfo.Local; // Use the local time zone of the server
    DateTime localTime = TimeZoneInfo.ConvertTimeFromUtc(utcNow, localTimeZone);

    // Set the ReadingDate to the current local time
    measurement.ReadingDate = localTime;
    
    // Convert the measurement object back to JSON for debugging
    string json = System.Text.Json.JsonSerializer.Serialize(measurement);

    // Print the received JSON
    Console.WriteLine("Received JSON: " + json);
    
    // Optionally, you can also log the JSON using a logging library:
    // _logger.LogInformation("Received JSON: " + json);

    // Uncomment this to save the measurement to the database
    // db.Measurements.Add(measurement);
    // await db.SaveChangesAsync();

    return Results.Created($"/measurements/{measurement.Id}", measurement);
});

app.Run();