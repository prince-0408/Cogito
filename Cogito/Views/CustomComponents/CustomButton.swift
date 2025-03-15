import SwiftUI

struct CustomButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case outline
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color("Primary")
            case .secondary:
                return Color("Secondary")
            case .destructive:
                return Color.red
            case .outline:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .outline:
                return Color("Primary")
            default:
                return .white
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline:
                return Color("Primary")
            default:
                return Color.clear
            }
        }
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor, lineWidth: style == .outline ? 2 : 0)
            )
        }
    }
}

