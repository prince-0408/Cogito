//
//  PressActions.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//
import SwiftUI

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

// View extension for press events
extension View {
    func pressEvents(onPress: @escaping () -> Void,
                    onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

// SafeArea helper
extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Your existing task list implementation
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

struct StatsView: View {
    var body: some View {
        NavigationView {
            Text("Statistics View")
                .navigationTitle("Statistics")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile View")
                .navigationTitle("Profile")
        }
    }
}
