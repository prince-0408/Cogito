import SwiftUI

struct TutorialTooltipView: View {
    @EnvironmentObject private var tutorialManager: TutorialManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    let step: TutorialStep
    let spotlightRect: CGRect
    
    // UI Constants matching the reference mockup
    private let tooltipWidth: CGFloat = 300
    private let caretSize: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 0) {
            // Caret Arrow Pointing UP (if tooltip is below spotlight)
            if step.arrowDirection == .up {
                CaretArrow(direction: .up)
                    .fill(Color("CardBackground"))
                    .frame(width: caretSize * 2, height: caretSize)
                    .offset(x: calculateCaretOffset())
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: -2)
            }
            
            // Popover Body Card
            VStack(alignment: .leading, spacing: 14) {
                // Header + Close Button
                HStack(alignment: .top) {
                    Text(step.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("Foreground"))
                    
                    Spacer()
                    
                    Button(action: {
                        tutorialManager.skipTutorial()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("TextPrimary").opacity(0.5))
                            .padding(4)
                            .background(Circle().fill(Color("Foreground").opacity(0.05)))
                    }
                    .accessibilityLabel("Skip tutorial")
                }
                
                // Description Text
                Text(step.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextPrimary").opacity(0.9))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Footer Navigation Controls
                HStack {
                    // Step Counter Index
                    Text("\(tutorialManager.currentStepIndex + 1)/\(tutorialManager.steps.count)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color("TextPrimary").opacity(0.6))
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Back Button
                        if tutorialManager.currentStepIndex > 0 {
                            Button(action: {
                                tutorialManager.previousStep()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.color)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .stroke(themeManager.currentTheme.color.opacity(0.3), lineWidth: 1.2)
                                    )
                            }
                            .accessibilityLabel("Previous tutorial step")
                        }
                        
                        // Primary Action Button ("Next" / "Done")
                        Button(action: {
                            tutorialManager.nextStep()
                        }) {
                            Text(tutorialManager.currentStepIndex == tutorialManager.steps.count - 1 ? "Done" : "Next")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(themeManager.currentTheme.color)
                                )
                                .shadow(color: themeManager.currentTheme.color.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .accessibilityLabel(tutorialManager.currentStepIndex == tutorialManager.steps.count - 1 ? "Complete feature tour" : "Next tutorial step")
                    }
                }
                .padding(.top, 4)
            }
            .padding(18)
            .frame(width: tooltipWidth)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color("CardBackground"))
                    .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
            )
            
            // Caret Arrow Pointing DOWN (if tooltip is above spotlight)
            if step.arrowDirection == .down {
                CaretArrow(direction: .down)
                    .fill(Color("CardBackground"))
                    .frame(width: caretSize * 2, height: caretSize)
                    .offset(x: calculateCaretOffset())
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
            }
        }
    }
    
    private func calculateCaretOffset() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let halfTooltip = tooltipWidth / 2
        
        // 1. Calculate where the tooltip center is placed
        let targetX = spotlightRect.midX
        let proposedTooltipX = targetX - halfTooltip
        let margin: CGFloat = 16
        let finalTooltipCenterX = max(margin, min(screenWidth - tooltipWidth - margin, proposedTooltipX)) + halfTooltip
        
        // 2. The difference is the offset of the caret from the tooltip center
        let deltaX = targetX - finalTooltipCenterX
        
        // 3. Limit to stay inside tooltip bounds
        let caretMargin: CGFloat = 25
        let limit = halfTooltip - caretMargin
        return max(-limit, min(limit, deltaX))
    }
}

struct CaretArrow: Shape {
    let direction: CoachmarkArrowDirection
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch direction {
        case .up:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        case .down:
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        default:
            break
        }
        
        return path
    }
}
