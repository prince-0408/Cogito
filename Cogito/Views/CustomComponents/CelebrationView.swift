import SwiftUI

struct CelebrationView: View {
    @Binding var isPresented: Bool
    let achievementType: AchievementType
    
    @State private var showCelebration = false
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            if showCelebration {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                
                // Celebration content
                VStack(spacing: 20) {
                    // Icon
                    Image(systemName: achievementType.icon)
                        .font(.system(size: 80))
                        .foregroundColor(achievementType.color)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    // Title
                    Text(achievementType.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(opacity)
                    
                    // Subtitle
                    Text(achievementType.subtitle)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(opacity)
                    
                    // Confetti particles
                    if achievementType.showConfetti {
                        ConfettiView()
                            .opacity(opacity)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(achievementType.backgroundColor)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .padding(40)
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                showCelebration = true
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1
                    opacity = 1
                }
                
                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCelebration = false
            isPresented = false
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        var newParticles: [ConfettiParticle] = []
        
        for _ in 0..<50 {
            let particle = ConfettiParticle(
                id: UUID(),
                position: CGPoint(x: CGFloat.random(in: 0...300), y: CGFloat.random(in: 0...300)),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 5...15),
                opacity: Double.random(in: 0.5...1)
            )
            newParticles.append(particle)
        }
        
        particles = newParticles
        
        // Animate particles falling
        withAnimation(.easeOut(duration: 2)) {
            for index in particles.indices {
                particles[index].position.y += 400
                particles[index].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

enum AchievementType {
    case firstTask
    case fiveTasks
    case allTasks
    case streak3
    case streak7
    
    var icon: String {
        switch self {
        case .firstTask: return "star.fill"
        case .fiveTasks: return "flame.fill"
        case .allTasks: return "checkmark.circle.fill"
        case .streak3: return "calendar.badge.checkmark"
        case .streak7: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstTask: return .yellow
        case .fiveTasks: return .orange
        case .allTasks: return .green
        case .streak3: return .blue
        case .streak7: return .purple
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .firstTask: return Color.yellow.opacity(0.9)
        case .fiveTasks: return Color.orange.opacity(0.9)
        case .allTasks: return Color.green.opacity(0.9)
        case .streak3: return Color.blue.opacity(0.9)
        case .streak7: return Color.purple.opacity(0.9)
        }
    }
    
    var title: String {
        switch self {
        case .firstTask: return "First Task Complete!"
        case .fiveTasks: return "5 Tasks Done!"
        case .allTasks: return "All Tasks Complete!"
        case .streak3: return "3 Day Streak!"
        case .streak7: return "7 Day Streak!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .firstTask: return "Great start! Keep the momentum going."
        case .fiveTasks: return "You're on fire! Keep up the great work."
        case .allTasks: return "Amazing! You've completed all your tasks for today."
        case .streak3: return "Consistency is key! Keep it up."
        case .streak7: return "Incredible! A whole week of productivity."
        }
    }
    
    var showConfetti: Bool {
        switch self {
        case .firstTask, .allTasks, .streak7: return true
        default: return false
        }
    }
}
