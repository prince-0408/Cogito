import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @EnvironmentObject private var aiViewModel: AIViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedInsight: AIInsight?
    @State private var showInsightDetail = false
    @State private var animateCharts = false
    
    // Interactive Graph Scrubber and Sector Highlights
    @State private var selectedCategoryName: String? = nil
    @State private var activeScrubberDate: Date? = nil
    @State private var activeScrubberValue: Int? = nil
    
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
                                    .font(.satoshi(.title3, weight: .bold))
                                    .foregroundColor(Color("Foreground"))
                                
                                Spacer()
                                
                                if aiViewModel.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.color))
                                }
                            }
                            
                            if aiViewModel.isProcessing {
                                VStack(spacing: 14) {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 8) {
                                            Text("🧠 Cogito AI is actively analyzing...")
                                                .font(.satoshi(size: 14, weight: .bold))
                                                .foregroundColor(themeManager.currentTheme.color)
                                            
                                            Text("Scanning completion rates and task priority distribution.")
                                                .font(.satoshi(size: 11, weight: .regular))
                                                .foregroundColor(Color("TextPrimary").opacity(0.6))
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    
                                    ShimmerCard()
                                    ShimmerCard()
                                }
                                .transition(.opacity)
                            } else if aiViewModel.insights.isEmpty {
                                Button(action: {
                                    aiViewModel.generateInsights(from: taskViewModel.tasks)
                                }) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                            .font(.satoshi(.headline, weight: .bold))
                                        Text("Generate AI Insights")
                                            .font(.satoshi(.headline, weight: .bold))
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
                                            .font(.satoshi(.subheadline, weight: .bold))
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
                                .font(.satoshi(.title3, weight: .bold))
                                .foregroundColor(Color("Foreground"))
                            
                            let categoryData = getCategoryData()
                            
                            if categoryData.isEmpty {
                                EmptyDataView(
                                    icon: "folder",
                                    title: "No category data",
                                    message: "Complete some tasks to see category statistics"
                                )
                            } else {
                                let chartDomain: [String] = categoryData.map { $0.category }
                                let chartRange: [AnyShapeStyle] = categoryData.map { item in
                                    let categoryName = item.category
                                    return AnyShapeStyle(
                                        LinearGradient(
                                            colors: [getCategoryColor(categoryName), getCategoryColor(categoryName).opacity(0.65)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                }
                                
                                Chart {
                                    ForEach(categoryData, id: \.category) { item in
                                        SectorMark(
                                            angle: .value("Count", animateCharts ? item.count : 0),
                                            innerRadius: .ratio(getInnerRadiusRatio(for: item.category)),
                                            outerRadius: .ratio(getOuterRadiusRatio(for: item.category)),
                                            angularInset: 1.5
                                        )
                                        .foregroundStyle(by: .value("Category", item.category))
                                        .annotation(position: .overlay) {
                                            Text("\(item.count)")
                                                .font(.satoshi(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                                .opacity(getAnnotationOpacity(for: item.category))
                                        }
                                        .opacity(getSliceOpacity(for: item.category))
                                    }
                                }
                                .chartForegroundStyleScale(
                                    domain: chartDomain,
                                    range: chartRange
                                )
                                .chartBackground { chartProxy in
                                    GeometryReader { geo in
                                        if let plotFrame = chartProxy.plotFrame {
                                            let frame = geo[plotFrame]
                                            ZStack {
                                                Circle()
                                                    .fill(Color("CardBackground"))
                                                    .frame(width: 110, height: 110)
                                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(
                                                                LinearGradient(
                                                                    colors: [Color.white.opacity(0.2), Color.clear],
                                                                    startPoint: .top,
                                                                    endPoint: .bottom
                                                                ),
                                                                lineWidth: 1
                                                            )
                                                    )
                                                
                                                VStack {
                                                    if let selectedCategory = selectedCategoryName,
                                                       let selectedItem = categoryData.first(where: { $0.category == selectedCategory }) {
                                                        Text("\(selectedItem.count)")
                                                            .font(.satoshi(size: 28, weight: .bold))
                                                            .foregroundColor(getCategoryColor(selectedCategory))
                                                            .transition(.scale.combined(with: .opacity))
                                                        
                                                        Text(selectedCategory.capitalized)
                                                            .font(.satoshi(size: 10, weight: .bold))
                                                            .foregroundColor(Color("TextPrimary").opacity(0.7))
                                                            .transition(.opacity)
                                                    } else {
                                                        Text("\(categoryData.reduce(0) { $0 + $1.count })")
                                                            .font(.satoshi(size: 24, weight: .bold))
                                                            .foregroundColor(Color("Foreground"))
                                                            .transition(.opacity)
                                                        
                                                        Text("Total")
                                                            .font(.satoshi(size: 10, weight: .bold))
                                                            .foregroundColor(Color("TextPrimary").opacity(0.7))
                                                            .transition(.opacity)
                                                    }
                                                }
                                                .id(selectedCategoryName ?? "total")
                                                .opacity(animateCharts ? 1 : 0)
                                            }
                                            .position(x: frame.midX, y: frame.midY)
                                        }
                                    }
                                }
                                .frame(height: 250)
                                .padding(.vertical)
                                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedCategoryName)
                                .accessibilityLabel("Task completion by category donut chart")
                                .accessibilityValue(selectedCategoryName != nil ? "Currently highlighting \(selectedCategoryName ?? "") category with \(categoryData.first(where: { $0.category == selectedCategoryName })?.count ?? 0) tasks." : "Total tasks: \(categoryData.reduce(0) { $0 + $1.count }).")
                                .accessibilityElement(children: .ignore)
                                
                                // Legend with interactive rows styled as beautiful dashboard elements
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(categoryData, id: \.category) { item in
                                        let isHighlighted = selectedCategoryName == item.category
                                        Button(action: {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                if selectedCategoryName == item.category {
                                                    selectedCategoryName = nil // Deselect
                                                } else {
                                                    selectedCategoryName = item.category
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [getCategoryColor(item.category), getCategoryColor(item.category).opacity(0.7)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 10, height: 10)
                                                    .shadow(color: getCategoryColor(item.category).opacity(isHighlighted ? 0.6 : 0.2), radius: 3)
                                                
                                                Text(item.category.capitalized)
                                                    .font(.satoshi(size: 13, weight: isHighlighted ? .bold : .medium))
                                                    .foregroundColor(isHighlighted ? getCategoryColor(item.category) : Color("TextPrimary"))
                                                
                                                Spacer()
                                                
                                                Text("\(item.count) tasks")
                                                    .font(.satoshi(size: 13, weight: isHighlighted ? .bold : .medium))
                                                    .foregroundColor(isHighlighted ? getCategoryColor(item.category) : Color("TextPrimary").opacity(0.6))
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(isHighlighted ? getCategoryColor(item.category).opacity(0.12) : Color("CardBackground").opacity(0.4))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(isHighlighted ? getCategoryColor(item.category).opacity(0.3) : Color.clear, lineWidth: 1)
                                                    )
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .accessibilityLabel("\(item.category.capitalized) category")
                                        .accessibilityValue("\(item.count) tasks")
                                        .accessibilityHint(isHighlighted ? "Double tap to clear the filter." : "Double tap to highlight the \(item.category.capitalized) slice inside the donut chart.")
                                        .accessibilityAddTraits(isHighlighted ? [.isButton, .isSelected] : [.isButton])
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color("CardBackground").opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color("CardBackground"))
                                
                                RoundedRectangle(cornerRadius: 24)
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
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                                              // Task Completion Trend
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                if let date = activeScrubberDate, let value = activeScrubberValue {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(themeManager.currentTheme.color)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("\(date.formatted(.dateTime.day().month())):")
                                            .font(.satoshi(size: 14, weight: .medium))
                                            .foregroundColor(Color("TextPrimary").opacity(0.8))
                                        
                                        Text("\(value) Completed")
                                            .font(.satoshi(size: 14, weight: .bold))
                                            .foregroundColor(themeManager.currentTheme.color)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(themeManager.currentTheme.color.opacity(0.12))
                                            .overlay(
                                                Capsule()
                                                    .stroke(themeManager.currentTheme.color.opacity(0.24), lineWidth: 1)
                                            )
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                } else {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Task Completion Trend")
                                            .font(.satoshi(.title3, weight: .bold))
                                            .foregroundColor(Color("Foreground"))
                                        
                                        Text("Complete tasks over time to see trends")
                                            .font(.satoshi(size: 12, weight: .medium))
                                            .foregroundColor(Color("TextPrimary").opacity(0.55))
                                    }
                                    .transition(.opacity)
                                }
                                Spacer()
                            }
                            .frame(height: 40)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: activeScrubberDate != nil)
                            
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
                                            y: .value("Completed", getCompletedCount(for: item.completed))
                                        )
                                        .foregroundStyle(themeManager.currentTheme.color)
                                        .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                                        .interpolationMethod(.catmullRom)
                                    }
                                    
                                    ForEach(trendData) { item in
                                        AreaMark(
                                            x: .value("Date", item.date),
                                            y: .value("Completed", getCompletedCount(for: item.completed))
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    themeManager.currentTheme.color.opacity(0.28),
                                                    themeManager.currentTheme.color.opacity(0.0)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.catmullRom)
                                    }
                                    
                                    ForEach(trendData) { item in
                                        PointMark(
                                            x: .value("Date", item.date),
                                            y: .value("Completed", getCompletedCount(for: item.completed))
                                        )
                                        .foregroundStyle(themeManager.currentTheme.color)
                                        .opacity(getPointMarkOpacity())
                                    }
                                    
                                    // Interactive scrubber markings
                                    if let scrubberDate = activeScrubberDate {
                                        RuleMark(
                                            x: .value("Selected Date", scrubberDate)
                                        )
                                        .foregroundStyle(themeManager.currentTheme.color.opacity(0.35))
                                        .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4]))
                                    }
                                    
                                    if let scrubberDate = activeScrubberDate, let scrubberValue = activeScrubberValue {
                                        // Outer border circle
                                        PointMark(
                                            x: .value("Selected Date", scrubberDate),
                                            y: .value("Selected Value", scrubberValue)
                                        )
                                        .foregroundStyle(themeManager.currentTheme.color)
                                        .symbolSize(180)
                                        
                                        // Inner white fill circle
                                        PointMark(
                                            x: .value("Selected Date", scrubberDate),
                                            y: .value("Selected Value", scrubberValue)
                                        )
                                        .foregroundStyle(.white)
                                        .symbolSize(70)
                                    }
                                }
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [4, 4]))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.06))
                                        AxisTick(stroke: StrokeStyle(lineWidth: 1))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.15))
                                        AxisValueLabel(format: .dateTime.day().month())
                                            .font(.satoshi(size: 9, weight: .bold))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.6))
                                    }
                                }
                                .accessibilityLabel("Task completion trend line graph")
                                .accessibilityValue(activeScrubberDate != nil ? "Selected date \(activeScrubberDate?.formatted(.dateTime.day().month(.wide)) ?? ""), \(activeScrubberValue ?? 0) completed tasks." : "14-day productivity trend. Average completed tasks per day is \(String(format: "%.1f", Double(trendData.reduce(0) { $0 + $1.completed }) / 14.0)).")
                                .accessibilityHint("Drag across the graph to scrub and read specific date details.")
                                .accessibilityElement(children: .ignore)
                                .chartOverlay { proxy in
                                    GeometryReader { geometry in
                                        Rectangle()
                                            .fill(Color.clear)
                                            .contentShape(Rectangle())
                                            .gesture(
                                                DragGesture(minimumDistance: 0)
                                                    .onChanged { value in
                                                        let location = value.location
                                                        if let date: Date = proxy.value(atX: location.x) {
                                                            // Find closest data point in trendData
                                                            if let closestPoint = trendData.min(by: {
                                                                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                                            }) {
                                                                if activeScrubberDate != closestPoint.date {
                                                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                                                    impact.impactOccurred()
                                                                }
                                                                withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                                                                    activeScrubberDate = closestPoint.date
                                                                    activeScrubberValue = closestPoint.completed
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .onEnded { _ in
                                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                                            activeScrubberDate = nil
                                                            activeScrubberValue = nil
                                                        }
                                                    }
                                            )
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color("CardBackground"))
                                
                                RoundedRectangle(cornerRadius: 24)
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
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // Task Priority Distribution
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Task Priority Distribution")
                                .font(.satoshi(.title3, weight: .bold))
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
                                            y: .value("Count", animateCharts ? item.count : 0),
                                            width: .fixed(45)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    getPriorityColor(item.priority),
                                                    getPriorityColor(item.priority).opacity(0.65)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(12, style: .continuous)
                                        .annotation(position: .top, spacing: 6) {
                                            Text("\(item.count)")
                                                .font(.satoshi(size: 12, weight: .bold))
                                                .foregroundColor(getPriorityColor(item.priority))
                                                .opacity(animateCharts ? 1.0 : 0.0)
                                        }
                                    }
                                }
                                .frame(height: 200)
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [4, 4]))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.06))
                                        AxisValueLabel()
                                            .font(.satoshi(size: 10, weight: .medium))
                                            .foregroundStyle(Color("TextPrimary").opacity(0.5))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .font(.satoshi(size: 11, weight: .bold))
                                            .foregroundStyle(Color("TextPrimary"))
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color("CardBackground"))
                                
                                RoundedRectangle(cornerRadius: 24)
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
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
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
    
    private func getInnerRadiusRatio(for category: String) -> Double {
        selectedCategoryName == category ? 0.42 : 0.5
    }
    
    private func getOuterRadiusRatio(for category: String) -> Double {
        selectedCategoryName == category ? 1.08 : 1.0
    }
    
    private func getSliceOpacity(for category: String) -> Double {
        selectedCategoryName == nil || selectedCategoryName == category ? 1.0 : 0.4
    }
    
    private func getAnnotationOpacity(for category: String) -> Double {
        selectedCategoryName == nil || selectedCategoryName == category ? 1.0 : 0.3
    }
    
    private func getCompletedCount(for count: Int) -> Int {
        animateCharts ? count : 0
    }
    
    private func getScrubberIndicatorColor() -> Color {
        themeManager.currentTheme.color
    }
    
    private func getPointMarkOpacity() -> Double {
        animateCharts && activeScrubberDate == nil ? 1.0 : 0.0
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
                    .font(.satoshi(.headline, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(colorForInsightType(insight.type))
                    )
                
                Text(insight.title)
                    .font(.satoshi(.headline, weight: .bold))
                    .foregroundColor(Color("Foreground"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("TextPrimary").opacity(0.5))
                    .font(.satoshi(.caption, weight: .regular))
            }
            
            Text(insight.description)
                .font(.satoshi(.subheadline, weight: .regular))
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
                    .font(.satoshi(.title2, weight: .bold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        Circle()
                            .fill(colorForInsightType(insight.type))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.satoshi(.title3, weight: .bold))
                        .foregroundColor(Color("Foreground"))
                    
                    Text(typeLabel(insight.type))
                        .font(.satoshi(.caption, weight: .medium))
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
                .font(.satoshi(.body, weight: .regular))
                .foregroundColor(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            // Recommendations section
            VStack(alignment: .leading, spacing: 15) {
                Text("Recommendations")
                    .font(.satoshi(.headline, weight: .bold))
                    .foregroundColor(Color("Foreground"))
                
                // Generate recommendations based on insight type
                ForEach(getRecommendations(for: insight), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(colorForInsightType(insight.type))
                        
                        Text(recommendation)
                            .font(.satoshi(.subheadline, weight: .regular))
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
                .font(.satoshi(size: 40, weight: .bold))
                .foregroundColor(Color("Primary").opacity(0.7))
            
            Text(title)
                .font(.satoshi(.headline, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(message)
                .font(.satoshi(.subheadline, weight: .regular))
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

