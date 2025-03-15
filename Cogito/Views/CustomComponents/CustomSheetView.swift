import SwiftUI

struct CustomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: Content
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    // Constants for animation and sizing
    private let maxOffset: CGFloat = 100
    private let dragThreshold: CGFloat = 50
    private let cornerRadius: CGFloat = 32
    
    init(isPresented: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background overlay
            Color.black.opacity(0.4 * (1.0 - (offset / maxOffset)))
                .ignoresSafeArea()
                .onTapGesture {
                    dismissSheet()
                }
            
            // Sheet content
            VStack(spacing: 0) {
                // Drag indicator
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    // Title
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("Foreground"))
                        .padding(.bottom, 16)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .background(Color("CardBackground").opacity(0.01)) // Nearly transparent for hit testing
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let newOffset = max(0, value.translation.height)
                            offset = newOffset
                        }
                        .onEnded { value in
                            isDragging = false
                            if value.translation.height > dragThreshold {
                                dismissSheet()
                            } else {
                                withAnimation(.spring()) {
                                    offset = 0
                                }
                            }
                        }
                )
                
                // Content
                ScrollView {
                    content
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color("CardBackground"))
                    
                    // Top edge highlight for depth
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
            .offset(y: offset)
            .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: offset)
            .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isDragging)
        }
        .transition(.move(edge: .bottom))
        .presentationDetents([.medium, .large])
    }
    
    private func dismissSheet() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = maxOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct ModernSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let sheetContent: SheetContent
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isPresented {
                        CustomSheetView(isPresented: $isPresented, title: title) {
                            sheetContent
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .zIndex(100)
                    }
                }
            )
    }
}

extension View {
    func modernSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(ModernSheetModifier(isPresented: isPresented, title: title, sheetContent: content()))
    }
}

