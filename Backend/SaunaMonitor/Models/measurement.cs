namespace SaunaMonitor.Models
{
    public class Measurement
    {
        public int Id { get; set; }
        public float TemperatureC { get; set; }
        public float Humidity { get; set; }
        public DateTime ReadingDate { get; set; }
        
    }
    
}


