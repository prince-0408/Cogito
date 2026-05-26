import SwiftUI

struct CelebrationView: View {
    @Binding var isPresented: Bool
    let achievementType: AchievementType
    
    @State private var showCelebration = false
    @State private var offset: CGFloat = -150
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -10
    
    var body: some View {
        ZStack {
            if showCelebration {
                // Background Tap-Through Confetti Layer
                if achievementType.showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false) // Let user tap through to the app underneath
                        .ignoresSafeArea()
                }
                
                // Premium Floating Toast Notification
                VStack {
                    HStack(spacing: 16) {
                        // Glowing Icon Wrapper
                        ZStack {
                            Circle()
                                .fill(achievementType.color.opacity(0.15))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [achievementType.color.opacity(0.5), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            Image(systemName: achievementType.icon)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(achievementType.color)
                                .shadow(color: achievementType.color.opacity(0.4), radius: 6, x: 0, y: 3)
                                .rotationEffect(.degrees(showCelebration ? 0 : -30))
                        }
                        
                        // Text Layout
                        VStack(alignment: .leading, spacing: 3) {
                            Text(achievementType.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color("Foreground"))
                            
                            Text(achievementType.subtitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("TextPrimary").opacity(0.85))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Dismiss Button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("TextPrimary").opacity(0.5))
                                .padding(8)
                                .background(Circle().fill(Color("Foreground").opacity(0.05)))
                        }
                        .accessibilityLabel("Dismiss celebration notification")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            // Ultra Thin Glass Backdrop
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.ultraThinMaterial)
                            
                            // Color Hue Underlay
                            RoundedRectangle(cornerRadius: 22)
                                .fill(achievementType.color.opacity(0.04))
                            
                            // High Fidelity Dual-Gradient Border
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.55),
                                            Color.white.opacity(0.05),
                                            achievementType.color.opacity(0.02),
                                            achievementType.color.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        }
                    )
                    // High Depth Premium Shadow
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .shadow(color: achievementType.color.opacity(0.06), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
                    .offset(y: offset)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10) // Align cleanly below Dynamic Island / Notch
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                // Snappy Spring Presentation
                showCelebration = true
                withAnimation(.spring(response: 0.45, dampingFraction: 0.76, blendDuration: 0)) {
                    offset = 0
                    scale = 1.0
                    rotation = 0
                    opacity = 1.0
                }
                
                // Play premium scattered haptic sparkles matching confetti falling physics:
                HapticManager.shared.playConfettiSparkles()
                
                // Non-intrusive Auto-Dismiss (Extended to 4s to allow reading)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    dismiss()
                }
            }
        }
    }
    
    private func dismiss() {
        // Snappy Dismissal upwards
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            offset = -150
            scale = 0.8
            rotation = 5
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showCelebration = false
            isPresented = false
        }
    }
}

// MARK: - Premium Confetti Physics Canvas

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiShape(shapeType: particle.shape)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(particle.position)
                        .shadow(color: particle.color.opacity(0.15), radius: 2, x: 0, y: 1)
                }
            }
            .onAppear {
                spawnConfetti(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }
    
    private func spawnConfetti(in size: CGSize) {
        let colors: [Color] = [
            .init(red: 1.0, green: 0.35, blue: 0.35), // Pastel Red
            .init(red: 0.35, green: 0.65, blue: 1.0), // Pastel Blue
            .init(red: 0.35, green: 0.85, blue: 0.45), // Pastel Green
            .init(red: 1.0, green: 0.85, blue: 0.35), // Pastel Yellow
            .init(red: 0.75, green: 0.45, blue: 1.0), // Pastel Purple
            .init(red: 1.0, green: 0.60, blue: 0.25)  // Pastel Orange
        ]
        
        var tempParticles: [ConfettiParticle] = []
        
        // Spawn particles along the top horizontal span
        for _ in 0..<75 {
            let shape = ConfettiShapeType.allCases.randomElement() ?? .circle
            let speedY = CGFloat.random(in: 4...9)
            let speedX = CGFloat.random(in: -2...2)
            
            let particle = ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: -60...(-10))
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 8...16),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -8...8),
                velocity: CGPoint(x: speedX, y: speedY),
                shape: shape
            )
            tempParticles.append(particle)
        }
        
        particles = tempParticles
    }
    
    private func updateParticles(in size: CGSize) {
        for index in particles.indices {
            // Apply simple wind, gravity, and speed physics
            particles[index].position.x += particles[index].velocity.x
            particles[index].position.y += particles[index].velocity.y
            
            // Flutter oscillation
            particles[index].velocity.x += CGFloat(sin(particles[index].rotation * 0.05)) * 0.15
            particles[index].rotation += particles[index].rotationSpeed
            
            // Terminal speed limits
            particles[index].velocity.y += 0.08 // Gentle gravity acceleration
        }
        
        // Remove particles that drifted fully out of the bottom viewport
        particles.removeAll { $0.position.y > size.height + 20 }
    }
}

// MARK: - Confetti Particle Helper Structures

enum ConfettiShapeType: CaseIterable {
    case circle
    case square
    case triangle
    case rectangle
}

struct ConfettiShape: Shape {
    let shapeType: ConfettiShapeType
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch shapeType {
        case .circle:
            path.addEllipse(in: rect)
        case .square:
            path.addRect(rect)
        case .triangle:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        case .rectangle:
            let narrowRect = CGRect(x: rect.minX, y: rect.minY + rect.height * 0.25, width: rect.width, height: rect.height * 0.5)
            path.addRect(narrowRect)
        }
        
        return path
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var rotation: Double
    let rotationSpeed: Double
    var velocity: CGPoint
    let shape: ConfettiShapeType
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
