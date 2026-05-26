import SwiftUI

// Preference key to collect coordinates of all spotlighted elements on screen
struct SpotlightPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]
    
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    // Spotlight modifier: registers the absolute position of a view dynamically
    func spotlight(id: String, active: Bool = true) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: SpotlightPreferenceKey.self,
                        value: active ? [id: geo.frame(in: .global)] : [:]
                    )
            }
        )
    }
}

// Custom shape that masks the background, cutting out the spotlighted element
struct SpotlightMask: Shape {
    let rect: CGRect
    let cornerRadius: CGFloat
    
    func path(in rectSpace: CGRect) -> Path {
        var path = Path()
        
        // Add full screen overlay bounds
        path.addRect(rectSpace)
        
        // Spotlight rounded cutout path
        let spotlightPath = Path(
            UIBezierPath(
                roundedRect: rect,
                cornerRadius: cornerRadius
            ).cgPath
        )
        
        // Add spotlight cutout path
        path.addPath(spotlightPath)
        
        return path
    }
}
