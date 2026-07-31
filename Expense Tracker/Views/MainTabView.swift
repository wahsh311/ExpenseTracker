import SwiftUI

enum Tab {
    case dashboard, history, settings
}

struct MainView: View {
    @State private var currentTab: Tab = .dashboard
    @State private var showAddExpense: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
                switch currentTab {
                case .dashboard:
                    DashboardView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                TabBarIcon(tab: .dashboard, icon: "chart.pie.fill", currentTab: $currentTab)
                
                Spacer()
                
                TabBarIcon(tab: .history, icon: "list.bullet.rectangle.portrait.fill", currentTab: $currentTab)
                
                Spacer()
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showAddExpense = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                        .offset(y: -20)
                }
                
                Spacer()
                
                TabBarIcon(tab: .settings, icon: "gearshape.fill", currentTab: $currentTab)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .environment(\.colorScheme, .dark)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .fullScreenCover(isPresented: $showAddExpense) {
            ZStack(alignment: .topTrailing) {
                AddExpenseView()
                
                Button(action: {
                    showAddExpense = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(20)
                }
            }
        }
    }
}

struct TabBarIcon: View {
    let tab: Tab
    let icon: String
    @Binding var currentTab: Tab
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == tab ? .white : .gray.opacity(0.5))
                
                Circle()
                    .fill(currentTab == tab ? Color.white : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 50, height: 50)
        }
    }
}
