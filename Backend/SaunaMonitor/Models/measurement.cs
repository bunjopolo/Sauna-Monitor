namespace SaunaMonitor.Models
{
    public class Measurement
    {
        public int Id { get; set; }
        public double TemperatureC { get; set; }
        public double Humidity { get; set; }
        public DateTime ReadingDate { get; set; }
        
        
    }
    
}


