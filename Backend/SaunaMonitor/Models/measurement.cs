using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SaunaMonitor.Models
{
    public class Measurement
    {
        public int Id { get; set; }

        [Required]
        public float TemperatureC { get; set; } // Tempaerature reading in C 

        public float Humidity { get; set; } // Humidity reading in %

        [Required] // Ensures that the date is always provided
        public DateTime MeasurementDate { get; set; } // Date and time of the reading
    }
}


