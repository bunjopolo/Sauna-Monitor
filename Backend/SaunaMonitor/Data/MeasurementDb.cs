namespace SaunaMonitor.Data;
using SaunaMonitor.Models;
using Microsoft.EntityFrameworkCore;

class MeasurementDb : DbContext
{
    public MeasurementDb(DbContextOptions<MeasurementDb> options)
        : base(options) { }

    public DbSet<Measurement> Measurements => Set<Measurement>();
}