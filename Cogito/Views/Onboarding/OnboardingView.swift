import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var progress: CGFloat = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("appTheme") private var appTheme: String = "blue"
    
    let pages = [
        OnboardingPage(
            title: "Cogito",
            subtitle: "Your AI Productivity Partner",
            description: "Revolutionize your workflow with intelligent task management and personalized insights.",
            imageName: "2",
            accentColor: .blue,
            gradient: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]
        ),
        OnboardingPage(
            title: "Smart Tasks",
            subtitle: "Intelligent Prioritization",
            description: "AI-powered suggestions that adapt to your work style, helping you focus on what matters most.",
            imageName: "11",
            accentColor: .green,
            gradient: [Color.green.opacity(0.7), Color.green.opacity(0.3)]
        ),
        OnboardingPage(
            title: "Insights",
            subtitle: "Productivity Analytics",
            description: "Gain deep understanding of your work patterns with interactive visualizations and recommendations.",
            imageName: "8",
            accentColor: .purple,
            gradient: [Color.purple.opacity(0.7), Color.purple.opacity(0.3)]
        ),
        OnboardingPage(
            title: "Personalize",
            subtitle: "Choose Your Theme",
            description: "Select a theme that matches your style and preferences.",
            imageName: "7",
            accentColor: .orange,
            gradient: [Color.orange.opacity(0.7), Color.orange.opacity(0.3)]
        ),
        OnboardingPage(
            title: "Ready to Begin",
            subtitle: "Your Journey Starts Here",
            description: "Transform your productivity with an intelligent, adaptive task management experience.",
            imageName: "5",
            accentColor: .blue,
            gradient: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: pages[currentPage].gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.7), value: currentPage)
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // Onboarding Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        if index == 3 { // Theme selection page
                            ThemeSelectionView(appTheme: $appTheme, isDarkMode: $isDarkMode)
                                .tag(index)
                        } else {
                            OnboardingPageView(
                                page: pages[index],
                                currentPage: $currentPage,
                                totalPages: pages.count,
                                onComplete: { hasCompletedOnboarding = true }
                            )
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.smooth, value: currentPage)
                
                Spacer()
                
                // Circular Progress Button
                OnboardingNavigationView(
                    currentPage: $currentPage,
                    progress: $progress,
                    totalPages: pages.count,
                    currentPageAccentColor: pages[currentPage].accentColor,
                    onComplete: { hasCompletedOnboarding = true }
                )
                .padding(.bottom, 30)
            }
        }
        .onChange(of: currentPage) { newValue in
            withAnimation(.smooth(duration: 0.6)) {
                progress = CGFloat(newValue) / CGFloat(pages.count - 1)
            }
        }
    }
}

struct OnboardingNavigationView: View {
    @Binding var currentPage: Int
    @Binding var progress: CGFloat
    let totalPages: Int
    let currentPageAccentColor: Color
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Advanced Circular Progress Button
            ZStack {
                // Layered Progress Rings
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 6)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // Enhanced Next/Complete Button
                Button(action: {
                    withAnimation(.smooth) {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                        } else {
                            onComplete()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: currentPage < totalPages - 1 ? "arrow.right" : "checkmark")
                            .foregroundColor(currentPageAccentColor)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 30)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let accentColor: Color
    let gradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimated = false
    @Binding var currentPage: Int
    let totalPages: Int
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                // Main feature image with animation - only center image now
                ImageCard(
                    imageName: page.imageName,
                    offset: CGSize(width: 0, height: isAnimated ? -20 : 0),
                    rotation: 0
                )
                .frame(height: 300)
                .padding(.bottom, 60)
                
                Spacer()
                
                // Onboarding Content
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.system(size: 40, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimated = true
            }
        }
    }
}

struct ImageCard: View {
    let imageName: String
    let offset: CGSize
    let rotation: Double
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 220, height: 280) // Slightly larger than before since it's the only image
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    OnboardingView()
}
