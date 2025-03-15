import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(Color("TextPrimary").opacity(0.7))
                    .frame(width: 24, height: 24)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color("Foreground"))
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Color("Foreground"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

