import Foundation
import SwiftUI

struct DayData: Identifiable {
    var id = UUID()
    var date: Date
    var taskCount: Int
    var completedCount: Int
    
    var intensity: Double {
        if taskCount == 0 { return 0 }
        return Double(completedCount) / Double(taskCount)
    }
    
    var color: Color {
        if taskCount == 0 { return Color.gray.opacity(0.2) }
        
        let completion = Double(completedCount) / Double(taskCount)
        
        if completion >= 0.8 {
            return Color("HighIntensity")
        } else if completion >= 0.5 {
            return Color("MediumIntensity")
        } else if completion > 0 {
            return Color("LowIntensity")
        } else {
            return Color("ZeroIntensity")
        }
    }
}

struct MonthData {
    var month: Date // First day of month
    var days: [DayData]
    
    static func generateEmptyMonth(for date: Date) -> MonthData {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numDays = range.count
        
        var days: [DayData] = []
        
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DayData(date: date, taskCount: 0, completedCount: 0))
            }
        }
        
        return MonthData(month: firstDayOfMonth, days: days)
    }
}

