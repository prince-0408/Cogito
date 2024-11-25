// Glass.swift - Creates a glass morphism effect
struct Glass: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .blur(radius: 10)
            .opacity(0.9)
    }
}
