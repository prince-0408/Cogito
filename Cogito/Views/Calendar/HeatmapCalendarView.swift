import SwiftUI
import Charts

struct HeatmapCalendarView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @StateObject private var heatmapViewModel: HeatmapViewModel
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
                
                VStack(spacing: 20) {
                    // Month selector
                    HStack {
                        Button(action: {
                            heatmapViewModel.selectPreviousMonth()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("Primary"))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color("CardBackground"))
                                )
                        }
                        
                        Spacer()
                        
                        if !heatmapViewModel.monthData.isEmpty {
                            let monthDate = heatmapViewModel.monthData[heatmapViewModel.selectedMonthIndex].month
                            Text(heatmapViewModel.getMonthName(for: monthDate))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            heatmapViewModel.selectNextMonth()
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("Primary"))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color("CardBackground"))
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Heatmap calendar
                    if !heatmapViewModel.monthData.isEmpty {
                        let days = heatmapViewModel.monthData[heatmapViewModel.selectedMonthIndex].days
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            // Day headers
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            
                            // Calendar days
                            ForEach(days) { day in
                                DayCell(day: day, isSelected: selectedDay?.id == day.id) {
                                    selectedDay = day
                                    showingTasksForDate = day.date
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("CardBackground"))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Productivity insights
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Productivity Insights")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        // Productivity chart
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Task Completion Rate")
                                .font(.subheadline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Chart {
                                ForEach(taskViewModel.calendarData.flatMap { $0.days }) { day in
                                    if day.taskCount > 0 {
                                        BarMark(
                                            x: .value("Date", day.date, unit: .day),
                                            y: .value("Completion Rate", day.intensity)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color("Primary"), Color("Secondary")],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                    }
                                }
                            }
                            .frame(height: 150)
                            .chartYScale(domain: 0...1)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel(format: .dateTime.day().month())
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("CardBackground"))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
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
                }
            }
            .onAppear {
                // Update the heatmapViewModel with the current taskViewModel
                heatmapViewModel.monthData = taskViewModel.calendarData
            }
        }

    }
}
struct DayCell: View {
    let day: DayData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                Text(day.date.formatted(.dateTime.day()))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color("Foreground"))
                
                if day.taskCount > 0 {
                    Text("\(day.completedCount)/\(day.taskCount)")
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color("TextPrimary").opacity(0.7))
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color("Primary") : day.color)
            )
        }
    }
}

struct TasksForDateView: View {
    let date: Date
    @EnvironmentObject private var taskViewModel: TaskViewModel
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
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Text(date.formatted(.dateTime.day().month().year()))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                        }
                        
                        Spacer()
                        
                        // Task count badge
                        VStack(alignment: .center, spacing: 4) {
                            Text("\(completedCount)/\(tasksForDate.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Primary"))
                            
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(Color("TextPrimary"))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackground"))
                        )
                    }
                    .padding(.horizontal)
                    
                    // Tasks list
                    if tasksForDate.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 60))
                                .foregroundColor(Color("Primary").opacity(0.7))
                            
                            Text("No tasks for this day")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Go Back")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color("Primary"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(tasksForDate) { task in
                                    TaskCard(task: task)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    HeatmapCalendarView(taskViewModel: TaskViewModel())
        .environmentObject(TaskViewModel())
        .preferredColorScheme(.dark)
}
