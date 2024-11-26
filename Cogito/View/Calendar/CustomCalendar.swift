//
//  CustomCalendar.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//

import SwiftUI

struct CustomCalendar: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let tasks: [Task]
    
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 20) {
            // Month selector
            HStack {
                Button {
                    withAnimation {
                        currentMonth = Calendar.current.date(
                            byAdding: .month,
                            value: -1,
                            to: currentMonth
                        ) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentMonth = Calendar.current.date(
                            byAdding: .month,
                            value: 1,
                            to: currentMonth
                        ) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Day headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(monthDates, id: \.self) { date in
                    if let date = date {
                        DateCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            hasTask: hasTask(on: date)
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var monthDates: [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        
        var dates: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: interval.start) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func hasTask(on date: Date) -> Bool {
        tasks.contains { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let hasTask: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue : Color.clear)
                .frame(width: 40, height: 40)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isSelected ? .white : .primary)
            
            if hasTask {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .offset(y: 12)
            }
        }
    }
}
