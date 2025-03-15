import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true
    @AppStorage("appTheme") private var appTheme: String = "blue"
    @EnvironmentObject private var aiViewModel: AIViewModel
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @State private var showingResetConfirmation = false
    @State private var showingNotificationPermission = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingThemeSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Background"),
                        Color("Background").opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // App Info
                        VStack(alignment: .center, spacing: 15) {
                            // App logo with animation
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("Primary"), Color("Primary").opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color("Primary").opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "brain")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Cogito")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color("Foreground"))
                            
                            Text("AI-Powered Task Manager")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(Color("TextPrimary").opacity(0.7))
                                .padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color("CardBackground"))
                                
                                // Top edge highlight for depth
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Appearance Settings
                        SettingsSection(
                            title: "Appearance",
                            icon: "paintpalette.fill",
                            iconColor: .purple
                        ) {
                            ToggleSetting(
                                title: "Dark Mode",
                                icon: "moon.fill",
                                isOn: $isDarkMode
                            )
                            
                            Button(action: {
                                showingThemeSelector = true
                            }) {
                                SettingsRow(
                                    title: "App Theme",
                                    icon: "paintpalette.fill",
                                    hasNavigation: true,
                                    trailingContent: {
                                        Circle()
                                            .fill(getThemeColor())
                                            .frame(width: 20, height: 20)
                                    }
                                )
                            }
                        }
                        
                        // AI Settings
                        SettingsSection(
                            title: "AI Features",
                            icon: "wand.and.stars",
                            iconColor: .blue
                        ) {
                            ToggleSetting(
                                title: "AI Suggestions",
                                icon: "wand.and.stars",
                                isOn: Binding(
                                    get: { aiViewModel.isEnabled },
                                    set: { aiViewModel.toggleAI(enabled: $0) }
                                )
                            )
                            
                            NavigationLink(destination: AIPreferencesView()) {
                                SettingsRow(
                                    title: "AI Preferences",
                                    icon: "gear",
                                    hasNavigation: true
                                )
                            }
                        }
                        
                        // Notification Settings
                        SettingsSection(
                            title: "Notifications",
                            icon: "bell.fill",
                            iconColor: .red
                        ) {
                            NavigationLink(destination: NotificationSettingsView()) {
                                SettingsRow(
                                    title: "Task Reminders",
                                    icon: "bell.fill",
                                    hasNavigation: true,
                                    trailingContent: {
                                        if notificationStatus == .authorized {
                                            Text("Enabled")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.green.opacity(0.2))
                                                )
                                        } else if notificationStatus == .denied {
                                            Text("Disabled")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.red.opacity(0.2))
                                                )
                                        }
                                    }
                                )
                            }
                            
                            if notificationStatus == .denied {
                                Button(action: {
                                    showingNotificationPermission = true
                                }) {
                                    HStack {
                                        Image(systemName: "bell.badge")
                                            .foregroundColor(.red)
                                            .frame(width: 24, height: 24)
                                        
                                        Text("Enable Notifications")
                                            .foregroundColor(Color("Foreground"))
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                        
                        // Data Management
                        SettingsSection(
                            title: "Data Management",
                            icon: "externaldrive.fill",
                            iconColor: .orange
                        ) {
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                SettingsRow(
                                    title: "Reset All Data",
                                    icon: "trash.fill",
                                    iconColor: .red,
                                    hasNavigation: false
                                )
                            }
                            
                            Button(action: {
                                hasCompletedOnboarding = false
                            }) {
                                SettingsRow(
                                    title: "Show Onboarding",
                                    icon: "arrow.clockwise",
                                    hasNavigation: false
                                )
                            }
                        }
                        
                        // About
                        SettingsSection(
                            title: "About",
                            icon: "info.circle",
                            iconColor: .green
                        ) {
                            NavigationLink(destination: AboutView()) {
                                SettingsRow(
                                    title: "About Cogito",
                                    icon: "info.circle",
                                    hasNavigation: true
                                )
                            }
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                SettingsRow(
                                    title: "Privacy Policy",
                                    icon: "lock.shield",
                                    hasNavigation: true
                                )
                            }
                            
                            NavigationLink(destination: TermsOfServiceView()) {
                                SettingsRow(
                                    title: "Terms of Service",
                                    icon: "doc.text",
                                    hasNavigation: true
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingResetConfirmation) {
                Alert(
                    title: Text("Reset All Data"),
                    message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        // Reset data logic
                        taskViewModel.taskDataService?.deleteAllTasks()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingNotificationPermission) {
                Alert(
                    title: Text("Enable Notifications"),
                    message: Text("To enable notifications, please go to your device settings and allow notifications for Cogito."),
                    primaryButton: .default(Text("Open Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            .modernSheet(isPresented: $showingThemeSelector, title: "Choose Theme") {
                ThemeSelectionView(appTheme: $appTheme, isDarkMode: $isDarkMode)
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private func checkNotificationStatus() {
        NotificationManager.shared.checkAuthorizationStatus { status in
            self.notificationStatus = status
        }
    }
    
    private func getThemeColor() -> Color {
        switch appTheme {
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        default:
            return .blue
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        iconColor: Color = Color("Primary"),
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(iconColor)
                    )
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Foreground"))
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackground"))
                    
                    // Top edge highlight for depth
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
}

struct SettingsRow<TrailingContent: View>: View {
    let title: String
    let icon: String
    var iconColor: Color = Color("Primary")
    var hasNavigation: Bool = true
    var trailingContent: () -> TrailingContent
    
    init(
        title: String,
        icon: String,
        iconColor: Color = Color("Primary"),
        hasNavigation: Bool = true,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.hasNavigation = hasNavigation
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("Foreground"))
            
            Spacer()
            
            trailingContent()
            
            if hasNavigation {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color("TextPrimary").opacity(0.5))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(Color("CardBackground").opacity(0.01)) // Nearly transparent for hit testing
    }
}

struct ToggleSetting: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("Primary"))
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("Foreground"))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("Primary"))
        }
        .padding()
        .contentShape(Rectangle())
        .background(Color("CardBackground").opacity(0.01)) // Nearly transparent for hit testing
    }
}



struct NotificationSettingsView: View {
    @AppStorage("enableReminders") private var enableReminders: Bool = true
    @AppStorage("defaultReminderTime") private var defaultReminderTime: Int = 30 // minutes
    @AppStorage("reminderSound") private var reminderSound: String = "Default"
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingPermissionAlert = false
    
    let reminderTimeOptions = [15, 30, 60, 120, 1440] // minutes (1440 = 1 day)
    let soundOptions = ["Default", "Subtle", "Urgent", "Gentle", "None"]
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Notification Status
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: notificationStatus == .authorized ? "bell.badge.fill" : "bell.slash")
                                .foregroundColor(notificationStatus == .authorized ? Color("Primary") : .red)
                                .font(.title2)
                            
                            Text("Notification Status")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Spacer()
                            
                            Text(notificationStatus == .authorized ? "Enabled" : "Disabled")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(notificationStatus == .authorized ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                )
                                .foregroundColor(notificationStatus == .authorized ? .green : .red)
                        }
                        
                        if notificationStatus == .denied {
                            Text("Notifications are currently disabled. Please enable them in your device settings.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Open Settings")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("Primary"))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                    .padding(.horizontal)
                    
                    // Enable Reminders
                    ToggleSetting(
                        title: "Enable Task Reminders",
                        icon: "bell.fill",
                        isOn: $enableReminders
                    )
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                    .padding(.horizontal)
                    .onChange(of: enableReminders) { newValue in
                        if newValue && notificationStatus != .authorized {
                            requestNotificationPermission()
                        }
                    }
                    
                    if enableReminders {
                        // Default Reminder Time
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Default Reminder Time")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Picker("Default Reminder Time", selection: $defaultReminderTime) {
                                Text("15 minutes before").tag(15)
                                Text("30 minutes before").tag(30)
                                Text("1 hour before").tag(60)
                                Text("2 hours before").tag(120)
                                Text("1 day before").tag(1440)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackground"))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Reminder Sound
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reminder Sound")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Picker("Reminder Sound", selection: $reminderSound) {
                                ForEach(soundOptions, id: \.self) { sound in
                                    Text(sound).tag(sound)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackground"))
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Explanation
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Notifications")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Cogito can send you reminders before your tasks are due. You can set a default reminder time here, or customize it for each task individually.")
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary").opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationStatus()
        }
        .alert(isPresented: $showingPermissionAlert) {
            Alert(
                title: Text("Enable Notifications"),
                message: Text("To receive task reminders, Cogito needs permission to send notifications."),
                primaryButton: .default(Text("Enable"), action: {
                    requestNotificationPermission()
                }),
                secondaryButton: .cancel(Text("Not Now"), action: {
                    enableReminders = false
                })
            )
        }
    }
    
    private func checkNotificationStatus() {
        NotificationManager.shared.checkAuthorizationStatus { status in
            self.notificationStatus = status
            
            // If reminders are enabled but notifications aren't authorized, show alert
            if enableReminders && status != .authorized && status != .notDetermined {
                showingPermissionAlert = true
            }
        }
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            checkNotificationStatus()
            if !granted {
                enableReminders = false
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // App Logo and Info
                    VStack(spacing: 15) {
                        Image(systemName: "brain")
                            .font(.system(size: 80))
                            .foregroundColor(Color("Primary"))
                        
                        Text("Cogito")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Foreground"))
                        
                        Text("AI-Powered Task Manager")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary").opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                    
                    // About Text
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About Cogito")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Cogito is an advanced AI-powered task manager that helps you organize, track, and optimize your workflow using artificial intelligence.")
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Key Features:")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                            .padding(.top, 5)
                        
                        FeatureItem(icon: "wand.and.stars", title: "AI Task Suggestions", description: "Get intelligent task recommendations based on your habits and patterns")
                        
                        FeatureItem(icon: "text.bubble.fill", title: "Natural Language Input", description: "Create tasks using natural language processing")
                        
                        FeatureItem(icon: "calendar.badge.clock", title: "Heatmap Calendar", description: "Visualize your productivity with an intuitive heatmap")
                        
                        FeatureItem(icon: "chart.bar.fill", title: "Productivity Insights", description: "Understand your workflow with AI-generated insights")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Credits")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Developed with ❤️ using SwiftUI")
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("AI powered by OpenAI")
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                    )
                }
                .padding()
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Color("Primary"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Foreground"))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color("TextPrimary").opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Foreground"))
                    
                    Text("Last Updated: March 1, 2025")
                        .font(.subheadline)
                        .foregroundColor(Color("TextPrimary").opacity(0.7))
                    
                    PolicySection(
                        title: "Information We Collect",
                        content: "Cogito collects task data that you input into the app. This includes task titles, descriptions, due dates, and completion status. We also collect usage data to improve the app experience."
                    )
                    
                    PolicySection(
                        title: "How We Use Your Information",
                        content: "We use your task data to provide the core functionality of the app, including AI-powered suggestions and insights. Your data is processed locally on your device whenever possible."
                    )
                    
                    PolicySection(
                        title: "OpenAI Integration",
                        content: "When you use AI features, your task data may be sent to OpenAI's servers for processing. This data is subject to OpenAI's privacy policy and terms of service."
                    )
                    
                    PolicySection(
                        title: "Data Storage",
                        content: "Your task data is stored locally on your device using CoreData. We do not store your data on our servers unless you explicitly enable cloud backup features."
                    )
                    
                    PolicySection(
                        title: "Your Rights",
                        content: "You have the right to access, correct, or delete your data at any time. You can export or delete all your data from the app settings."
                    )
                    
                    PolicySection(
                        title: "Changes to This Policy",
                        content: "We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page."
                    )
                    
                    Text("If you have any questions about this privacy policy, please contact us.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("Foreground"))
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Foreground"))
                    
                    Text("Last Updated: March 1, 2025")
                        .font(.subheadline)
                        .foregroundColor(Color("TextPrimary").opacity(0.7))
                    
                    PolicySection(
                        title: "Acceptance of Terms",
                        content: "By using Cogito, you agree to these Terms of Service. If you do not agree to these terms, please do not use the app."
                    )
                    
                    PolicySection(
                        title: "Use of the Service",
                        content: "Cogito provides an AI-powered task management service. You may use the service for personal or business purposes in accordance with these terms."
                    )
                    
                    PolicySection(
                        title: "User Accounts",
                        content: "You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account."
                    )
                    
                    PolicySection(
                        title: "Intellectual Property",
                        content: "The app and its original content, features, and functionality are owned by Cogito and are protected by international copyright, trademark, and other intellectual property laws."
                    )
                    
                    PolicySection(
                        title: "Limitation of Liability",
                        content: "In no event shall Cogito be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses."
                    )
                    
                    PolicySection(
                        title: "Changes to Terms",
                        content: "We reserve the right to modify these terms at any time. We will provide notice of any significant changes by updating the date at the top of these terms."
                    )
                    
                    Text("If you have any questions about these terms, please contact us.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}

