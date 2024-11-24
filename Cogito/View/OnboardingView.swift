// OnboardingView.swift
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    let pages = [
        OnboardingPage(
            title: "Welcome to AI Task Manager",
            description: "Manage your tasks efficiently with AI-powered suggestions",
            systemImage: "brain.head.profile"
        ),
        OnboardingPage(
            title: "Smart Suggestions",
            description: "Get intelligent suggestions on how to complete your tasks effectively",
            systemImage: "lightbulb.fill"
        ),
        OnboardingPage(
            title: "Stay Organized",
            description: "Categorize tasks, set priorities, and never miss a deadline",
            systemImage: "calendar.badge.clock"
        ),
        OnboardingPage(
            title: "Customizable Themes",
            description: "Choose from various themes to personalize your experience",
            systemImage: "paintpalette.fill"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: pages[index].systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text(pages[index].title)
                        .font(.title)
                        .bold()
                    
                    Text(pages[index].description)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    if index == pages.count - 1 {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(themeManager.currentTheme.primaryColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}