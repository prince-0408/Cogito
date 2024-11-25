import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Custom calendar
                CustomCalendar(
                    selectedDate: $selectedDate,
                    currentMonth: $currentMonth,
                    tasks: viewModel.tasks
                )
                .modifier(GlassmorphicBackground())
                .padding(.horizontal)
                
                // Tasks for selected date
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tasks for \(formatDate(selectedDate))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(tasksForSelectedDate) { task in
                        TaskCard(task: task, viewModel: viewModel)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var tasksForSelectedDate: [Task] {
        viewModel.tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
