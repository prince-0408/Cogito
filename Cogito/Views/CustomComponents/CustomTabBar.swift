import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs = [
        TabItem(icon: "house.fill", title: "Home"),
        TabItem(icon: "calendar", title: "Heatmap"),
        TabItem(icon: "chart.bar.fill", title: "Insights"),
        TabItem(icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Spacer()
                TabButton(
                    item: tabs[index],
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }
                )
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
//        .background(
//            Capsule()
//                .fill(Color.black.opacity(0.2))
//        )
        .frame(height: 60)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color.clear)
    }
}

struct TabItem {
    let icon: String
    let title: String
}

struct TabButton: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? Color.blue : Color.gray.opacity(0.6))
                
                if isSelected {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.blue)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, isSelected ? 16 : 0)
            .padding(.vertical, 10)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
    }
}
#Preview {
    CustomTabBar(selectedTab: .constant(0))
        .preferredColorScheme(.light)
}


