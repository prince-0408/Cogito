import SwiftUI
import Charts

struct HeatmapCalendarView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @StateObject private var heatmapViewModel: HeatmapViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDay: DayData?
    @State private var showingTasksForDate: Date?
    
    init(taskViewModel: TaskViewModel) {
        // Initialize with the passed TaskViewModel
        _heatmapViewModel = StateObject(wrappedValue: HeatmapViewModel(taskViewModel: taskViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Month selector
                        HStack {
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                heatmapViewModel.selectPreviousMonth()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.color)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color("CardBackground"))
                                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                    )
                            }
                            
                            Spacer()
                            
                            if !heatmapViewModel.monthData.isEmpty {
                                let monthDate = heatmapViewModel.monthData[heatmapViewModel.selectedMonthIndex].month
                                Text(heatmapViewModel.getMonthName(for: monthDate))
                                    .font(.satoshi(size: 20, weight: .bold))
                                    .foregroundColor(Color("Foreground"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                heatmapViewModel.selectNextMonth()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.color)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color("CardBackground"))
                                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Heatmap calendar
                        if !heatmapViewModel.monthData.isEmpty {
                            let days = heatmapViewModel.monthData[heatmapViewModel.selectedMonthIndex].days
                            
                            // Calculate weekday offset for the first day of this month
                            let paddingCount: Int = {
                                guard let firstDay = days.first?.date else { return 0 }
                                let weekday = Calendar.current.component(.weekday, from: firstDay)
                                return weekday - 1 // 1 is Sunday, so if Sunday, 0 padding spaces
                            }()
                            
                            VStack(spacing: 12) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                                    // Day headers
                                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                        Text(day)
                                            .font(.satoshi(size: 11, weight: .medium))
                                            .foregroundColor(Color("TextPrimary").opacity(0.5))
                                            .frame(maxWidth: .infinity)
                                    }
                                    
                                    // Padding days representing empty spaces of the previous month
                                    ForEach(0..<paddingCount, id: \.self) { _ in
                                        Color.clear
                                            .frame(height: 44)
                                    }
                                    
                                    // Calendar days of the month
                                    ForEach(days) { day in
                                        DayCell(
                                            day: day,
                                            isSelected: selectedDay?.id == day.id,
                                            themeColor: themeManager.currentTheme.color,
                                            isDarkMode: themeManager.isDarkMode
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                selectedDay = day
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                    .background(Color("TextPrimary").opacity(0.08))
                                    .padding(.vertical, 4)
                                
                                // Clean Contribution Legend
                                HStack {
                                    Text("Less")
                                        .font(.satoshi(size: 11, weight: .medium))
                                        .foregroundColor(Color("TextPrimary").opacity(0.5))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        ForEach(0..<4) { level in
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(level == 0 
                                                      ? (themeManager.isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)) 
                                                      : themeManager.currentTheme.color.opacity(Double(level) * 0.28 + 0.1))
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("More")
                                        .font(.satoshi(size: 11, weight: .medium))
                                        .foregroundColor(Color("TextPrimary").opacity(0.5))
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color("CardBackground"))
                                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Selected Day Dashboard Summary
                        if let day = selectedDay {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(day.date.formatted(.dateTime.weekday(.wide)))
                                            .font(.satoshi(size: 11, weight: .bold))
                                            .foregroundColor(themeManager.currentTheme.color)
                                            .textCase(.uppercase)
                                        
                                        Text(day.date.formatted(.dateTime.day().month().year()))
                                            .font(.satoshi(size: 18, weight: .bold))
                                            .foregroundColor(Color("Foreground"))
                                    }
                                    
                                    Spacer()
                                    
                                    // Task completion rate badge
                                    HStack(spacing: 6) {
                                        Image(systemName: day.intensity >= 1.0 && day.taskCount > 0 ? "checkmark.circle.fill" : "circle.dashed")
                                            .foregroundColor(day.intensity >= 1.0 && day.taskCount > 0 ? .green : themeManager.currentTheme.color)
                                            .font(.system(size: 14, weight: .semibold))
                                        
                                        Text("\(day.completedCount)/\(day.taskCount) Tasks")
                                            .font(.satoshi(size: 13, weight: .bold))
                                            .foregroundColor(Color("Foreground"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(themeManager.currentTheme.color.opacity(0.1))
                                    )
                                }
                                
                                if day.taskCount > 0 {
                                    Button(action: {
                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                        impact.impactOccurred()
                                        showingTasksForDate = day.date
                                    }) {
                                        HStack {
                                            Text("View & Manage Tasks")
                                                .font(.satoshi(size: 14, weight: .bold))
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .font(.satoshi(size: 13, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [themeManager.currentTheme.color, themeManager.currentTheme.color.opacity(0.85)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: themeManager.currentTheme.color.opacity(0.15), radius: 6, x: 0, y: 3)
                                    }
                                } else {
                                    Text("No tasks scheduled for this day.")
                                        .font(.satoshi(size: 13, weight: .regular))
                                        .foregroundColor(Color("TextPrimary").opacity(0.6))
                                        .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color("CardBackground"))
                                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
                        }
                        
                        // Productivity insights
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Productivity Insights")
                                .font(.satoshi(size: 18, weight: .bold))
                                .foregroundColor(Color("Foreground"))
                                .padding(.horizontal, 4)
                            
                             // Productivity chart
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(themeManager.currentTheme.color)
                                        .font(.satoshi(.headline, weight: .bold))
                                    
                                    Text("Task Completion Rate")
                                        .font(.satoshi(size: 14, weight: .bold))
                                        .foregroundColor(Color("Foreground"))
                                }
                                
                                Chart {
                                    ForEach(taskViewModel.calendarData.flatMap { $0.days }) { day in
                                        if day.taskCount > 0 {
                                            BarMark(
                                                x: .value("Date", day.date, unit: .day),
                                                y: .value("Completion Rate", day.intensity),
                                                width: .fixed(12)
                                            )
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [themeManager.currentTheme.color, themeManager.currentTheme.color.opacity(0.45)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(6, style: .continuous)
                                        }
                                    }
                                }
                                .frame(height: 150)
                                .chartYScale(domain: 0...1)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [2, 4]))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.12))
                                        AxisTick()
                                        AxisValueLabel(format: .dateTime.day().month())
                                            .font(.satoshi(size: 9, weight: .medium))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.5))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: [0.0, 0.5, 1.0]) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [2, 4]))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.12))
                                        AxisValueLabel {
                                            if let rate = value.as(Double.self) {
                                                Text("\(Int(rate * 100))%")
                                                    .font(.satoshi(size: 9, weight: .medium))
                                                    .foregroundStyle(Color("TextPrimary").opacity(0.5))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color("CardBackground"))
                                    
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.3), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Productivity Heatmap")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: Binding(
                get: { showingTasksForDate != nil },
                set: { if !$0 { showingTasksForDate = nil } }
            )) {
                if let date = showingTasksForDate {
                    TasksForDateView(date: date)
                        .environmentObject(taskViewModel)
                        .environmentObject(themeManager)
                }
            }
            .onAppear {
                // Update the heatmapViewModel with the current taskViewModel
                heatmapViewModel.monthData = taskViewModel.calendarData
                
                // Select today's date automatically if available
                let today = Date()
                if let currentMonth = taskViewModel.calendarData.first {
                    if let todayData = currentMonth.days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                        selectedDay = todayData
                    }
                }
            }
        }
    }
}

struct DayCell: View {
    let day: DayData
    let isSelected: Bool
    let themeColor: Color
    let isDarkMode: Bool
    let onTap: () -> Void
    
    var body: some View {
        let hasTasks = day.taskCount > 0
        let completionRate = hasTasks ? Double(day.completedCount) / Double(day.taskCount) : 0.0
        
        // Dynamic cell color
        let cellColor: Color = {
            if isSelected {
                return themeColor
            }
            if !hasTasks {
                return isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
            }
            // Heatmap intensity matching theme color
            if completionRate >= 0.8 {
                return themeColor.opacity(0.9)
            } else if completionRate >= 0.5 {
                return themeColor.opacity(0.6)
            } else if completionRate > 0 {
                return themeColor.opacity(0.3)
            } else {
                return themeColor.opacity(0.12)
            }
        }()
        
        let textColor: Color = {
            if isSelected {
                return .white
            }
            if !hasTasks {
                return Color("Foreground").opacity(0.6)
            }
            if completionRate >= 0.8 {
                return .white
            }
            return Color("Foreground")
        }()
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(cellColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeColor.opacity(isSelected ? 0.35 : 0.0), lineWidth: 1.5)
                    )
                    .shadow(color: isSelected ? themeColor.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                
                VStack(spacing: 2) {
                    Text(String(Calendar.current.component(.day, from: day.date)))
                        .font(.satoshi(size: 14, weight: isSelected || completionRate >= 0.8 ? .bold : .medium))
                        .foregroundColor(textColor)
                    
                    if hasTasks {
                        Circle()
                            .fill(isSelected ? .white : (completionRate >= 0.8 ? .white.opacity(0.8) : themeColor))
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(day.date.formatted(.dateTime.day().month(.wide).year()))
        .accessibilityValue(hasTasks ? "\(day.completedCount) completed out of \(day.taskCount) tasks. Completion rate \(Int(completionRate * 100))%." : "No tasks scheduled.")
        .accessibilityHint("Double tap to select and display the focus dashboard for this date.")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

struct TasksForDateView: View {
    let date: Date
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
    // Computed property to get tasks for the date
    private var tasksForDate: [Task] {
        taskViewModel.getTasksForDate(date)
    }
    
    // Computed property to get completed task count
    private var completedCount: Int {
        tasksForDate.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(date.formatted(.dateTime.weekday(.wide)))
                                .font(.satoshi(size: 11, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.color)
                                .textCase(.uppercase)
                            
                            Text(date.formatted(.dateTime.day().month().year()))
                                .font(.satoshi(size: 24, weight: .bold))
                                .foregroundColor(Color("Foreground"))
                        }
                        
                        Spacer()
                        
                        // Task count badge
                        VStack(alignment: .center, spacing: 4) {
                            Text("\(completedCount)/\(tasksForDate.count)")
                                .font(.satoshi(size: 20, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.color)
                            
                            Text("Completed")
                                .font(.satoshi(size: 10, weight: .bold))
                                .foregroundColor(Color("TextPrimary").opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("CardBackground"))
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Tasks list
                    if tasksForDate.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 60))
                                .foregroundColor(themeManager.currentTheme.color.opacity(0.6))
                            
                            Text("No tasks for this day")
                                .font(.satoshi(size: 16, weight: .bold))
                                .foregroundColor(Color("TextPrimary"))
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Go Back")
                                    .font(.satoshi(size: 14, weight: .bold))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 14)
                                    .background(themeManager.currentTheme.color)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                ForEach(tasksForDate) { task in
                                    TaskCard(task: task) {
                                        withAnimation {
                                            if task.isCompleted {
                                                var updatedTask = task
                                                updatedTask.isCompleted = false
                                                updatedTask.completedDate = nil
                                                taskViewModel.updateTask(updatedTask)
                                            } else {
                                                taskViewModel.markTaskAsCompleted(task)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Day's Focus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.satoshi(size: 15, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.color)
                    }
                }
            }
        }
    }
}

#Preview {
    HeatmapCalendarView(taskViewModel: TaskViewModel())
        .environmentObject(TaskViewModel())
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}
