//
//  ContentView.swift
//  SaunaApp
//
//  Created by Eli Garlick on 2024-12-09.
//

import SwiftUI
import SwiftyJSON
import Foundation


struct ContentView: View {
    @StateObject var webSocketManager = WebSocketManager()
    
    var body: some View {
        TabView {
            // First Tab: Temperature Gauge View
            TemperatureGaugeView()
                .tabItem {
                    Label("Data", systemImage: "thermometer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear(){
            webSocketManager.connect()
        }
    }
}


struct SettingsView: View {
    @StateObject var sensorData = SensorData()
    
    var body: some View {
        NavigationView {
            List(sensorData.Infos) { info in
                VStack(alignment: .leading) {
                    Text("Temperature: \(info.temperature)°C")
                        .font(.headline)
                    Text("Humidity: \(info.humidity)%")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Measurements")
            .onAppear {
                print("Loaded Infos: \(sensorData.Infos)")
            }
        }
    }
}


struct TemperatureGaugeView: View {
    
    @StateObject var sensorData = SensorData()
    
    @State private var temperature: Double = 100.0 // Initial temperature value
    @State private var humidity: Double = 70.0 // Initial humidity
    @State private var totalHours: Int = 25 // Example total hours
    @State private var saunasPerWeek: Int = 3 // Example saunas per week
    

    var statusEmoji: String {
        if let latestTemperature = sensorData.Infos.first?.temperature,
           let temperatureFloat = Float(latestTemperature) {
            return temperatureFloat > 75 ? "🔥" : "❄️"
        }
        return "❌"
    }
    
    
    
    var body: some View {
    
        VStack {
            VStack {
                Text(statusEmoji)
                    .font(.system(size: 100)) // Adjust size as needed
            }
            
            if let latestTemperature = sensorData.Infos.first?.temperature,
               let temperatureFloat = Float(latestTemperature),
               let latestHumidity = sensorData.Infos.first?.humidity,
               let humidityFloat = Float(latestHumidity){
                
                
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
                            .trim(from: 0, to: CGFloat(temperatureFloat / 110) * 0.75)
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
                        
                        Text("\(Int(temperatureFloat))°C")
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
                            .trim(from: 0, to: CGFloat(humidityFloat / 100) * 0.75)
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
                        
                        Text("\(Int(humidityFloat))%")
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//data structure
struct Info: Identifiable{
    var id: String
    var temperature: String
    var humidity: String
}


class SensorData: ObservableObject {
    @Published var Infos = [Info]()
    
    init() {
        
        // create URL object
        let env = ProcessInfo.processInfo.environment
        
        // get endpoint from environment variables
        if let urlString = env["DATA_ENDPOINT"], let url = URL(string: urlString){
            
            //start session
            let session = URLSession(configuration: .default)
            session.dataTask(with: url) { (data, _, err) in
                if let err = err {
                    print("Error: \(err.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                //load data from json response
                do {
                    let json = try JSON(data: data)
                    for item in json.arrayValue {
                        let temperature = item["temperatureC"].stringValue
                        let humidity = item["humidity"].stringValue
                        DispatchQueue.main.async {
                            self.Infos.append(Info(id: UUID().uuidString, temperature: temperature, humidity: humidity))
                        }
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
}



class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    
    @Published var recievedMessage: String = ""
    
    private var webSocketURL: URL?
    
    // create URL object
    init(){
        let env = ProcessInfo.processInfo.environment
        if let webSocketURLString = env["WEBSOCKET_ENDPOINT"], let url = URL(string: webSocketURLString){
            self.webSocketURL = url
            connect()
        } else {
            print("Error: Websocket URL environment variable not found")
        }
    }
    
    // connect to the websocket server
    func connect() {
        guard let url = webSocketURL else {
            print("Invalid websocket URL")
            return
        }
        
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    // Listen for messages from the WebSocket server
    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                // Handle the incoming message
                if case .string(let text) = message {
                    DispatchQueue.main.async {
                        self?.recievedMessage = text
                    }
                }
                // Keep listening for new messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("Failed to receive message: \(error.localizedDescription)")
            }
        }
    }
    
    
    // Send a message to the WebSocket server
    func sendMessage(_ message: String) {
        guard let webSocketTask = webSocketTask else { return }
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    // Disconnect from the WebSocket server
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    
    
}

