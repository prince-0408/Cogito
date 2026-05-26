import SwiftUI

struct ShimmerCard: View {
    @State private var startPoint = UnitPoint(x: -1.8, y: -1.2)
    @State private var endPoint = UnitPoint(x: -0.6, y: -0.2)
    
    var body: some View {
        let shimmerColors = [
            Color("CardBackground").opacity(0.4),
            Color.white.opacity(0.12),
            Color("CardBackground").opacity(0.4)
        ]
        
        VStack(alignment: .leading, spacing: 14) {
            // Header Text Line Placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(Color("TextPrimary").opacity(0.08))
                .frame(width: 140, height: 18)
            
            // Subtitle Text Line Placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(Color("TextPrimary").opacity(0.05))
                .frame(maxWidth: .infinity)
                .frame(height: 12)
            
            // Bottom Meta Layout Placeholder
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("TextPrimary").opacity(0.06))
                    .frame(width: 80, height: 10)
                
                Spacer()
                
                Circle()
                    .fill(Color("TextPrimary").opacity(0.08))
                    .frame(width: 16, height: 16)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            ZStack {
                // Glassmorphic Backdrop
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("CardBackground").opacity(0.6))
                
                // Sweeping diagonal Shimmer reflection overlay
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: shimmerColors,
                            startPoint: startPoint,
                            endPoint: endPoint
                        )
                    )
            }
        )
        // High fidelity outline
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(
                .linear(duration: 1.6)
                .repeatForever(autoreverses: false)
            ) {
                // Diagonal sweep across the screen physical boundaries
                startPoint = UnitPoint(x: 1.2, y: 1.8)
                endPoint = UnitPoint(x: 2.4, y: 2.8)
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Background").ignoresSafeArea()
        
        VStack(spacing: 16) {
            ShimmerCard()
            ShimmerCard()
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
