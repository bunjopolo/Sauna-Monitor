//
//  ContentView.swift
//  SaunaApp
//
//  Created by Eli Garlick on 2024-12-09.
//

import SwiftUI
import SwiftyJSON




struct ContentView: View {
    var body: some View {
        TabView {
            // First Tab: Temperature Gauge View
            TemperatureGaugeView()
                .tabItem {
                    Label("Temperature", systemImage: "thermometer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            

        }
    }
}


struct SettingsView: View {
    @State private var notificationPermission = false

    var body: some View {
        HStack {
            Text("Hello World")
                
            }
        }
    }


struct TemperatureGaugeView: View {
    @State private var temperature: Double = 100.0 // Initial temperature value
    @State private var humidity: Double = 70.0 // Initial humidity
    @State private var totalHours: Int = 25 // Example total hours
    @State private var saunasPerWeek: Int = 3 // Example saunas per week

    var statusEmoji: String {
        return temperature > 75 ? "🔥" : "❄️"
    }

    var body: some View {
        VStack {
            VStack {
                Text(statusEmoji)
                    .font(.system(size: 100)) // Adjust size as needed
            }

            HStack {
                // Temperature Gauge
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            Color.gray.opacity(0.2),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))

                    Circle()
                        .trim(from: 0, to: CGFloat(temperature / 110) * 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.red, .blue]),
                                center: .center,
                                startAngle: .degrees(150),
                                endAngle: .degrees(45)
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))

                    Text("\(Int(temperature))°C")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(width: 150, height: 150)
                .padding()

                // Humidity Gauge
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            Color.gray.opacity(0.2),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))

                    Circle()
                        .trim(from: 0, to: CGFloat(humidity / 100) * 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.red, .blue]),
                                center: .center,
                                startAngle: .degrees(150),
                                endAngle: .degrees(45)
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))

                    Text("\(Int(humidity))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(width: 150, height: 150)
                .padding()
            }

            // Additional Data Fields
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Total Hours:")
                        .font(.headline)
                    Spacer()
                    Text("\(totalHours)")
                        .font(.body)
                }
                HStack {
                    Text("Saunas Per Week:")
                        .font(.headline)
                    Spacer()
                    Text("\(saunasPerWeek)")
                        .font(.body)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// Demo for how to get data

//struct Info: Identifiable{
//    var id: String
//    var name: String
//    var model: String
//    var manufacturer: String
//}
//
//class Testinfo: ObservableObject{
//    @Published var Infos = [Info]()
//    init(){
//        let source = "https://swapi.dev/api/starships/"
//        let url = URL(string: source)!
//        let session = URLSession(configuration: .default)
//        session.dataTask(with: url){ (data, _, err) in
//            if err != nil{
//                print((err?.localizedDescription)!)
//            }
//            let json = try! JSON(data: data!)
//            for i in json["results"]{
//                let name = i.1["name"].stringValue
//                let model = i.1["model"].stringValue
//                let manufacturer = i.1["manufacturer"].stringValue
//                DispatchQueue.main.async {
//                    self.Infos.append(Info(id: "\(name), \(model)", name: name, model: model, manufacturer: manufacturer))
//                }
//            }
//        }.resume()
//    }
//}
