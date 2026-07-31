import SwiftUI

// 1. إضافة شاشة السجل (history) لقائمة التابات
enum Tab {
    case dashboard, history, settings
}

struct MainPremiumView: View {
    @State private var currentTab: Tab = .dashboard
    @State private var showAddExpense: Bool = false // للتحكم بظهور شاشة الإضافة
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. الشاشات الرئيسية
            Group {
                switch currentTab {
                case .dashboard:
                    UltraPremiumDashboardView()
                case .history:
                    // 👈 تم إضافة شاشة السجل هنا
                    UltraPremiumHistoryView()
                case .settings:
                    UltraPremiumSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. شريط التنقل العائم (Floating Tab Bar)
            HStack {
                // زر الرئيسية
                TabBarIcon(tab: .dashboard, icon: "chart.pie.fill", currentTab: $currentTab)
                
                Spacer()
                
                // زر السجل (History) 👈 الجديد
                TabBarIcon(tab: .history, icon: "list.bullet.rectangle.portrait.fill", currentTab: $currentTab)
                
                Spacer()
                
                // زر الإضافة العائم (Floating Action Button)
                Button(action: {
                    // اهتزاز خفيف عند الضغط
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    showAddExpense = true // إظهار شاشة الإضافة
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        // تدرج لوني عصري للزر
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                        .offset(y: -20) // رفعه للأعلى لكسر حدود الشريط
                }
                
                Spacer()
                
                // زر الإعدادات
                TabBarIcon(tab: .settings, icon: "gearshape.fill", currentTab: $currentTab)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            // تأثير الزجاج (Glassmorphism)
            .background(.ultraThinMaterial, in: Capsule())
            .environment(\.colorScheme, .dark) // إجبار التأثير الزجاجي على اللون الداكن
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        // عرض شاشة الإضافة بشكل منبثق (Modal)
        .fullScreenCover(isPresented: $showAddExpense) {
            // إضافة زر الإغلاق داخل شاشة UltraPremiumAddExpenseView
            ZStack(alignment: .topTrailing) {
                UltraPremiumAddExpenseView()
                
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

// مكون مساعد لتصميم أيقونات الـ TabBar
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
                
                // نقطة صغيرة تظهر تحت الأيقونة المفعلة
                Circle()
                    .fill(currentTab == tab ? Color.white : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 50, height: 50)
        }
    }
}
