import SwiftUI // ضفناها عشان نتعرف على الـ Color
import Combine

class BudgetViewModel: ObservableObject {
    @Published var salary: Double = 1000.0
    
    // 1. بيانات الرسم البياني الخطي
    @Published var weeklyData: [(day: String, amount: Double)] = [
        ("Mon", 15), ("Tue", 35), ("Wed", 20), ("Thu", 80),
        ("Fri", 45), ("Sat", 10), ("Sun", 65)
    ]
    
    // 2. بيانات الرسم الدائري
    @Published var categoryData: [(category: String, amount: Double, color: Color)] = [
        ("Food 🍔", 120, .orange),
        ("Transport 🚕", 45, .blue),
        ("Coffee ☕️", 30, .brown),
        ("Bills 💡", 80, .purple)
    ]
    
    // 3. الحركات (كانت recentTransactions وصارت هي المصاريف الفعلية)
    @Published var currentMonthExpenses: [ExpenseTransaction] = [
        ExpenseTransaction(title: "Starbucks", icon: "cup.and.saucer.fill", amount: 4.50, time: "Today, 09:41 AM", color: .brown),
        ExpenseTransaction(title: "Uber", icon: "car.fill", amount: 12.00, time: "Yesterday, 06:20 PM", color: .blue),
        ExpenseTransaction(title: "Netflix", icon: "play.tv.fill", amount: 9.99, time: "28 Jul, 11:00 AM", color: .red)
    ]
    
    // --- الحسابات الرياضية ---
    
    var totalSpentThisMonth: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        max(salary - totalSpentThisMonth, 0)
    }
    
    var daysRemainingInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return 1 }
        let totalDays = range.count
        let currentDay = calendar.component(.day, from: today)
        let remaining = totalDays - currentDay + 1
        
        return remaining > 0 ? remaining : 1
    }
    
    var safeToSpendToday: Double {
        remainingBalance / Double(daysRemainingInMonth)
    }
}
