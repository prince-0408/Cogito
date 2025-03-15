import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    @State private var selectedInsight: AIInsight?
    @State private var showInsightDetail = false
    @State private var animateCharts = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Background"),
                        Color("Background").opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // AI Insights
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("AI Insights")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("Foreground"))
                                
                                Spacer()
                                
                                if aiViewModel.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                                }
                            }
                            
                            if aiViewModel.isProcessing {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 15) {
                                        LottieAnimationView(name: "loading")
                                            .frame(width: 120, height: 120)
                                        
                                        Text("Analyzing your tasks...")
                                            .font(.subheadline)
                                            .foregroundColor(Color("TextPrimary").opacity(0.7))
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("CardBackground"))
                                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                )
                            } else if aiViewModel.insights.isEmpty {
                                Button(action: {
                                    aiViewModel.generateInsights(from: taskViewModel.tasks)
                                }) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                            .font(.headline)
                                        Text("Generate AI Insights")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color("Primary"), Color("Primary").opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color("Primary").opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                            } else {
                                // Insights carousel
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(aiViewModel.insights) { insight in
                                            InsightCard(insight: insight)
                                                .onTapGesture {
                                                    selectedInsight = insight
                                                    showInsightDetail = true
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                }
                                
                                // Refresh button
                                Button(action: {
                                    aiViewModel.generateInsights(from: taskViewModel.tasks)
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Refresh Insights")
                                            .font(.subheadline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Primary").opacity(0.15))
                                    .foregroundColor(Color("Primary"))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Task Completion by Category
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Task Completion by Category")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                            
                            let categoryData = getCategoryData()
                            
                            if categoryData.isEmpty {
                                EmptyDataView(
                                    icon: "folder",
                                    title: "No category data",
                                    message: "Complete some tasks to see category statistics"
                                )
                            } else {
                                ZStack {
                                    Chart {
                                        ForEach(categoryData, id: \.category) { item in
                                            SectorMark(
                                                angle: .value("Count", animateCharts ? item.count : 0),
                                                innerRadius: .ratio(0.5),
                                                angularInset: 1.5
                                            )
                                            .foregroundStyle(by: .value("Category", item.category))
                                            .annotation(position: .overlay) {
                                                Text("\(item.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .opacity(animateCharts ? 1 : 0)
                                            }
                                        }
                                    }
                                    .chartForegroundStyleScale(domain: categoryData.map { $0.category }, range: categoryData.map { getCategoryColor($0.category) })
                                    
                                    // Center circle with total count
                                    VStack {
                                        Text("\(categoryData.reduce(0) { $0 + $1.count })")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("Foreground"))
                                        
                                        Text("Total")
                                            .font(.caption)
                                            .foregroundColor(Color("TextPrimary"))
                                    }
                                    .opacity(animateCharts ? 1 : 0)
                                }
                                .frame(height: 250)
                                .padding(.vertical)
                                
                                // Legend
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(categoryData, id: \.category) { item in
                                        HStack {
                                            Circle()
                                                .fill(getCategoryColor(item.category))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(item.category)
                                                .font(.subheadline)
                                                .foregroundColor(Color("TextPrimary"))
                                            
                                            Spacer()
                                            
                                            Text("\(item.count) tasks")
                                                .font(.subheadline)
                                                .foregroundColor(Color("TextPrimary").opacity(0.7))
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("CardBackground"))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color("CardBackground").opacity(0.5))
                                .padding(.horizontal, 8)
                        )
                        .padding(.vertical, 10)
                        
                        // Task Completion Trend
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Task Completion Trend")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                            
                            let trendData = getTrendData()
                            
                            if trendData.isEmpty {
                                EmptyDataView(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "No trend data",
                                    message: "Complete tasks over time to see your productivity trends"
                                )
                            } else {
                                Chart {
                                    ForEach(trendData) { item in
                                        LineMark(
                                            x: .value("Date", item.date),
                                            y: .value("Completed", animateCharts ? item.completed : 0)
                                        )
                                        .foregroundStyle(Color("Primary"))
                                        .interpolationMethod(.catmullRom)
                                        
                                        AreaMark(
                                            x: .value("Date", item.date),
                                            y: .value("Completed", animateCharts ? item.completed : 0)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color("Primary").opacity(0.5), Color("Primary").opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.catmullRom)
                                        
                                        PointMark(
                                            x: .value("Date", item.date),
                                            y: .value("Completed", animateCharts ? item.completed : 0)
                                        )
                                        .foregroundStyle(Color("Primary"))
                                        .opacity(animateCharts ? 1 : 0)
                                    }
                                }
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                                        AxisGridLine()
                                        AxisTick()
                                        AxisValueLabel(format: .dateTime.day().month())
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color("CardBackground").opacity(0.5))
                                .padding(.horizontal, 8)
                        )
                        .padding(.vertical, 10)
                        
                        // Task Priority Distribution
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Task Priority Distribution")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Foreground"))
                            
                            let priorityData = getPriorityData()
                            
                            if priorityData.isEmpty {
                                EmptyDataView(
                                    icon: "exclamationmark.triangle",
                                    title: "No priority data",
                                    message: "Add tasks with different priorities to see distribution"
                                )
                            } else {
                                Chart {
                                    ForEach(priorityData, id: \.priority) { item in
                                        BarMark(
                                            x: .value("Priority", item.priority),
                                            y: .value("Count", animateCharts ? item.count : 0)
                                        )
                                        .foregroundStyle(getPriorityColor(item.priority))
                                        .cornerRadius(8)
                                    }
                                }
                                .frame(height: 200)
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color("CardBackground").opacity(0.5))
                                .padding(.horizontal, 8)
                        )
                        .padding(.vertical, 10)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if aiViewModel.insights.isEmpty && !taskViewModel.tasks.isEmpty {
                    aiViewModel.generateInsights(from: taskViewModel.tasks)
                }
                
                // Animate charts after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        animateCharts = true
                    }
                }
            }
            .onDisappear {
                animateCharts = false
            }
            .modernSheet(isPresented: $showInsightDetail, title: "Insight Details") {
                if let insight = selectedInsight {
                    InsightDetailView(insight: insight)
                }
            }
        }
    }
    
    // Helper functions for chart data
    private func getCategoryData() -> [(category: String, count: Int)] {
        var categoryCount: [String: Int] = [:]
        
        for category in TaskCategory.allCases {
            let count = taskViewModel.tasks.filter { $0.category == category }.count
            if count > 0 {
                categoryCount[category.rawValue] = count
            }
        }
        
        return categoryCount.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        if let category = TaskCategory(rawValue: category) {
            return category.color
        }
        return .gray
    }
    
    private func getTrendData() -> [TrendDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -14, to: today)!
        
        var trendData: [TrendDataPoint] = []
        
        for dayOffset in 0..<14 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let completedTasks = taskViewModel.tasks.filter { task in
                guard let completedDate = task.completedDate else { return false }
                return calendar.isDate(completedDate, inSameDayAs: date)
            }.count
            
            trendData.append(TrendDataPoint(date: date, completed: completedTasks))
        }
        
        return trendData
    }
    
    private func getPriorityData() -> [(priority: String, count: Int)] {
        var priorityCount: [String: Int] = [:]
        
        for priority in TaskPriority.allCases {
            let count = taskViewModel.tasks.filter { $0.priority == priority }.count
            if count > 0 {
                priorityCount[priority.rawValue] = count
            }
        }
        
        return priorityCount.map { ($0.key, $0.value) }
    }
    
    private func getPriorityColor(_ priority: String) -> Color {
        if let priority = TaskPriority(rawValue: priority) {
            return priority.color
        }
        return .gray
    }
}

struct InsightCard: View {
    let insight: AIInsight
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForInsightType(insight.type))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(colorForInsightType(insight.type))
                    )
                
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(Color("Foreground"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("TextPrimary").opacity(0.5))
                    .font(.caption)
            }
            
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 300)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("CardBackground"))
                
                // Top edge highlight for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            // Add haptic feedback
            let impactGenerator = UIImpactFeedbackGenerator(style: .light)
            impactGenerator.impactOccurred()
            
            // Animate press effect
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    private func iconForInsightType(_ type: AIInsight.InsightType) -> String {
        switch type {
        case .productivity:
            return "chart.bar.fill"
        case .pattern:
            return "repeat"
        case .suggestion:
            return "lightbulb.fill"
        }
    }
    
    private func colorForInsightType(_ type: AIInsight.InsightType) -> Color {
        switch type {
        case .productivity:
            return Color.blue
        case .pattern:
            return Color.purple
        case .suggestion:
            return Color.orange
        }
    }
}

struct InsightDetailView: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack {
                Image(systemName: iconForInsightType(insight.type))
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        Circle()
                            .fill(colorForInsightType(insight.type))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Foreground"))
                    
                    Text(typeLabel(insight.type))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(colorForInsightType(insight.type).opacity(0.2))
                        )
                        .foregroundColor(colorForInsightType(insight.type))
                }
            }
            .padding(.bottom, 10)
            
            // Divider
            Rectangle()
                .fill(Color("TextPrimary").opacity(0.1))
                .frame(height: 1)
            
            // Description
            Text(insight.description)
                .font(.body)
                .foregroundColor(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            // Recommendations section
            VStack(alignment: .leading, spacing: 15) {
                Text("Recommendations")
                    .font(.headline)
                    .foregroundColor(Color("Foreground"))
                
                // Generate recommendations based on insight type
                ForEach(getRecommendations(for: insight), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(colorForInsightType(insight.type))
                        
                        Text(recommendation)
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardBackground").opacity(0.5))
            )
            
            Spacer()
            
            // Action button
            Button(action: {
                // Action based on insight type
            }) {
                HStack {
                    Image(systemName: actionIconFor(insight.type))
                    Text(actionTextFor(insight.type))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [colorForInsightType(insight.type), colorForInsightType(insight.type).opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: colorForInsightType(insight.type).opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding()
    }
    
    private func iconForInsightType(_ type: AIInsight.InsightType) -> String {
        switch type {
        case .productivity:
            return "chart.bar.fill"
        case .pattern:
            return "repeat"
        case .suggestion:
            return "lightbulb.fill"
        }
    }
    
    private func colorForInsightType(_ type: AIInsight.InsightType) -> Color {
        switch type {
        case .productivity:
            return Color.blue
        case .pattern:
            return Color.purple
        case .suggestion:
            return Color.orange
        }
    }
    
    private func typeLabel(_ type: AIInsight.InsightType) -> String {
        switch type {
        case .productivity:
            return "Productivity Insight"
        case .pattern:
            return "Pattern Recognition"
        case .suggestion:
            return "Suggestion"
        }
    }
    
    private func getRecommendations(for insight: AIInsight) -> [String] {
        // Generate recommendations based on insight type and content
        switch insight.type {
        case .productivity:
            return [
                "Schedule your most important tasks during your peak productivity hours",
                "Break down large tasks into smaller, manageable chunks",
                "Use the Pomodoro technique to maintain focus and productivity"
            ]
        case .pattern:
            return [
                "Leverage your identified patterns to optimize your schedule",
                "Be aware of your work habits and adjust accordingly",
                "Create routines that align with your natural productivity cycles"
            ]
        case .suggestion:
            return [
                "Implement the suggested changes to improve your workflow",
                "Try the recommended approach for at least two weeks",
                "Track the results to see if the suggestion improves your productivity"
            ]
        }
    }
    
    private func actionIconFor(_ type: AIInsight.InsightType) -> String {
        switch type {
        case .productivity:
            return "arrow.up.forward.circle.fill"
        case .pattern:
            return "calendar.badge.clock"
        case .suggestion:
            return "checkmark.circle.fill"
        }
    }
    
    private func actionTextFor(_ type: AIInsight.InsightType) -> String {
        switch type {
        case .productivity:
            return "Apply Productivity Tips"
        case .pattern:
            return "Optimize Schedule"
        case .suggestion:
            return "Implement Suggestion"
        }
    }
}

struct EmptyDataView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color("Primary").opacity(0.7))
            
            Text(title)
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary").opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct LottieAnimationView: View {
    let name: String
    
    var body: some View {
        // This is a placeholder for a Lottie animation
        // In a real app, you would integrate Lottie here
        ZStack {
            Circle()
                .fill(Color("Primary").opacity(0.1))
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                .scaleEffect(1.5)
        }
    }
}

struct TrendDataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var completed: Int
}

