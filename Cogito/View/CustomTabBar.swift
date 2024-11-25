// CustomTabBar.swift
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Namespace private var namespace
    @EnvironmentObject var themeManager: ThemeManager
    
    // Define tab bar items
    let tabs: [TabBarItem] = [
        TabBarItem(iconName: "house.fill", title: "Home", tab: .home),
        TabBarItem(iconName: "calendar", title: "Calendar", tab: .calendar),
        TabBarItem(iconName: "plus.circle.fill", title: "Add", tab: .add),
        TabBarItem(iconName: "chart.bar.fill", title: "Stats", tab: .stats),
        TabBarItem(iconName: "person.fill", title: "Profile", tab: .profile)
    ]
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Spacer()
                if tab.tab == .add {
                    AddButton(tab: tab, selectedTab: $selectedTab)
                } else {
                    TabBarButton(
                        tab: tab,
                        selectedTab: $selectedTab,
                        namespace: namespace
                    )
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            Glass()
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}
