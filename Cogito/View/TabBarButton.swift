// TabBarButton.swift
struct TabBarButton: View {
    let tab: TabBarItem
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab.tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20))
                    .frame(height: 20)
                
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(selectedTab == tab.tab ? themeManager.currentTheme.primaryColor : .gray)
            .overlay {
                if selectedTab == tab.tab {
                    Capsule()
                        .fill(themeManager.currentTheme.primaryColor)
                        .frame(height: 2)
                        .offset(y: 16)
                        .matchedGeometryEffect(id: "tab", in: namespace)
                }
            }
        }
    }
}