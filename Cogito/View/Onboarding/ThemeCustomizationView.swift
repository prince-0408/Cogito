// ThemeCustomizationView.swift
struct ThemeCustomizationView: View {
    @State private var selectedTheme = ThemeManager.AppTheme.default
    @State private var showingPreview = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Personalize Your Experience")
                .font(.title)
                .bold()
            
            // Theme Preview
            VStack(spacing: 15) {
                Text("Choose Your Theme")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                            ThemePreviewCard(theme: theme, isSelected: selectedTheme == theme)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTheme = theme
                                        showingPreview = true
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            
            if showingPreview {
                // Live Preview
                VStack(spacing: 15) {
                    Text("Preview")
                        .font(.headline)
                    
                    // Sample Task List Preview
                    VStack {
                        SampleTaskRow(
                            title: "Important Meeting",
                            priority: .high,
                            theme: selectedTheme
                        )
                        
                        SampleTaskRow(
                            title: "Project Review",
                            priority: .medium,
                            theme: selectedTheme
                        )
                    }
                    .padding()
                    .background(selectedTheme.backgroundColor)
                    .cornerRadius(15)
                }
                .padding()
                .transition(.scale)
            }
            
            Button(action: {
                themeManager.currentTheme = selectedTheme
            }) {
                Text("Apply Theme")
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .padding()
                    .background(selectedTheme.primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}