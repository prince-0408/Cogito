import Foundation
import SwiftUI
import Combine

class HeatmapViewModel: ObservableObject {
    @Published var monthData: [MonthData] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedMonthIndex: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(taskViewModel: TaskViewModel) {
        // Subscribe to changes in the task view model's calendar data
        taskViewModel.$calendarData
            .sink { [weak self] calendarData in
                self?.monthData = calendarData
            }
            .store(in: &cancellables)
    }
    
    func getMonthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func getDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func getDayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func isToday(date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func selectNextMonth() {
        if selectedMonthIndex < monthData.count - 1 {
            selectedMonthIndex += 1
        }
    }
    
    func selectPreviousMonth() {
        if selectedMonthIndex > 0 {
            selectedMonthIndex -= 1
        }
    }
}

