//
//  OnboardingView.swift
//  Cogito
//
//  Created by Prince Yadav on 08/12/24.
//

import SwiftUI

// MARK: - Views
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationProgress)
                
                // Blurred Overlay
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Page Content
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(viewModel.pages.indices, id: \.self) { index in
                            OnboardingPageView(
                                pageModel: viewModel.pages[index],
                                geometry: geometry
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Page Indicator
                    pageIndicator(in: geometry)
                    
                    // Navigation Buttons
                    navigationButtons
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.6),
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func pageIndicator(in geometry: GeometryProxy) -> some View {
        HStack(spacing: 10) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .scaleEffect(index == viewModel.currentPage ? 1.2 : 1.0)
                    .animation(.spring(), value: viewModel.currentPage)
            }
        }
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack {
            // Previous Button
            if !viewModel.isFirstPage {
                Button(action: viewModel.moveToPreviousPage) {
                    Text("Previous")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            
            Spacer()
            
            // Next/Start Button
            Button(action: viewModel.moveToNextPage) {
                Text(viewModel.isLastPage ? "Get Started" : "Next")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func startAnimations() {
        withAnimation(
            Animation.easeInOut(duration: 3)
            .repeatForever(autoreverses: true)
        ) {
            animationProgress = 1.0
        }
    }
}

struct OnboardingPageView: View {
    let pageModel: OnboardingPageModel
    let geometry: GeometryProxy
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated Icon
            Image(systemName: pageModel.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                .offset(y: animationOffset)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: animationOffset
                )
                .onAppear {
                    animationOffset = -20
                }
            
            // Glassmorphic Content Container
            glassmorphicContainer {
                VStack(spacing: 15) {
                    Text(pageModel.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(pageModel.subtitle)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(pageModel.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                }
                .padding()
            }
        }
        .padding()
    }
    
    private func glassmorphicContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                Color.white.opacity(0.1)
            )
            .background(
                BlurView(style: .systemUltraThinMaterial) )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Previews
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.light)
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}

// Standalone Page Preview
struct OnboardingPagePreview: View {
    @State private var selectedPage: OnboardingPageModel
    
    init() {
        let viewModel = OnboardingViewModel()
        _selectedPage = State(initialValue: viewModel.pages[0])
    }
    
    var body: some View {
        GeometryReader { geometry in
            OnboardingPageView(
                pageModel: selectedPage,
                geometry: geometry
            )
            .previewDisplayName("Individual Page Preview")
        }
    }
}
