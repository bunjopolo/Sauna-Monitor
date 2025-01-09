//
//  CalendarView.swift
//  SaunaApp
//
//  Created by Eli Garlick on 2024-12-09.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedMonth: Date = Date() // Current month
    @State private var dailyHours: [Int] = Array(repeating: 0, count: 31) // Example data for hours per day
    
    let calendar = Calendar.current
    let daysInWeek = 7

    var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else { return [] }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack {
            // Header with Month, Year, and Arrows
            HStack {
                Button(action: {
                    changeMonth(by: -1) // Go to previous month
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                }
                
                Spacer()
                
                Text(monthYearString(selectedMonth))
                    .font(.title)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    changeMonth(by: 1) // Go to next month
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.bottom, 10)
            
            // Days of the Week Labels
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 10)
            
            // Calendar Grid
            let gridItems = Array(repeating: GridItem(.flexible()), count: daysInWeek)
            LazyVGrid(columns: gridItems, spacing: 15) {
                ForEach(daysInMonth, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    let hours = dailyHours[day - 1] // Hours for the current day
                    VStack {
                        ZStack {
                            Circle()
                                .fill(hours > 0 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                                .frame(width: CGFloat(30 + hours * 2), height: CGFloat(30 + hours * 2)) // Circle size based on hours
                            
                            Text("\(day)")
                                .font(.headline)
                        }
                        if hours > 0 {
                            Text("\(hours) hrs")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            generateExampleHours()
        }
    }
    
    // Function to generate example hours for the days in the selected month
    private func generateExampleHours() {
        if let range = calendar.range(of: .day, in: .month, for: selectedMonth) {
            dailyHours = Array(repeating: 0, count: range.count).map { _ in Int.random(in: 0...10) }
        }
    }
    
    // Helper to change the month
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
            generateExampleHours() // Update data for the new month
        }
    }
    
    // Helper to format month and year as a string
    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
}
