import Foundation
import SwiftUI

enum BreakdownRange: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}

class DashboardViewModel: ObservableObject {
    @AppStorage("monthlySalary") var salary: Double = 1000.0
    @AppStorage("fixedExpenses") var fixedExpenses: Double = 0.0
    
    // متغيرات التنقل والفلاتر صارت هون
    @Published var weekOffset: Int = 0
    @Published var selectedBreakdownRange: BreakdownRange = .month
    @Published var breakdownOffset: Int = 0

    // --- حسابات الرصيد الأساسية ---
    func totalSpentThisMonth(from expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                       .reduce(0) { $0 + $1.amount }
    }
    
    func remainingBalance(from expenses: [Expense]) -> Double {
        max((salary - fixedExpenses) - totalSpentThisMonth(from: expenses), 0)
    }
    
    func safeToSpendToday(from expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return 0 }
        let remainingDays = range.count - calendar.component(.day, from: today) + 1
        return remainingBalance(from: expenses) / Double(max(remainingDays, 1))
    }
    
    // --- 1. منطق الرسم الخطي الأسبوعي ---
    var selectedWeekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date()) ?? Date()
    }
    
    var weekLabel: String {
        if weekOffset == 0 {
            return "This Week"
        } else {
            let calendar = Calendar.current
            let endDate = selectedWeekEndDate
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
    
    func dynamicWeeklyData(from expenses: [Expense]) -> [(day: String, amount: Double)] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: selectedWeekEndDate)
        var data: [(day: String, amount: Double)] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: endDate) {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                let dayName = formatter.string(from: date)
                let dailyTotal = expenses.filter { calendar.isDate($0.date, inSameDayAs: date) }
                                         .reduce(0) { $0 + $1.amount }
                data.append((day: dayName, amount: dailyTotal))
            }
        }
        return data
    }
    
    // --- 2. منطق الرسم الدائري (Breakdown) ---
    var breakdownLabel: String {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        
        if breakdownOffset == 0 {
            switch selectedBreakdownRange {
            case .day: return "Today"
            case .week: return "This Week"
            case .month: return "This Month"
            }
        }
        
        switch selectedBreakdownRange {
        case .day:
            let date = calendar.date(byAdding: .day, value: breakdownOffset, to: today) ?? today
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        case .week:
            let endDate = calendar.date(byAdding: .day, value: breakdownOffset * 7, to: today) ?? today
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        case .month:
            let date = calendar.date(byAdding: .month, value: breakdownOffset, to: today) ?? today
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    func filteredExpensesForBreakdown(from expenses: [Expense]) -> [Expense] {
        let calendar = Calendar.current
        let today = Date()
        
        return expenses.filter { expense in
            switch selectedBreakdownRange {
            case .day:
                let targetDay = calendar.date(byAdding: .day, value: breakdownOffset, to: today) ?? today
                return calendar.isDate(expense.date, inSameDayAs: targetDay)
            case .week:
                let targetWeekEnd = calendar.date(byAdding: .day, value: breakdownOffset * 7, to: today) ?? today
                let weekStart = calendar.date(byAdding: .day, value: -6, to: targetWeekEnd) ?? targetWeekEnd
                return expense.date >= calendar.startOfDay(for: weekStart) && expense.date <= calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: targetWeekEnd))!
            case .month:
                let targetMonth = calendar.date(byAdding: .month, value: breakdownOffset, to: today) ?? today
                let components = calendar.dateComponents([.year, .month], from: targetMonth)
                let expenseComponents = calendar.dateComponents([.year, .month], from: expense.date)
                return components.year == expenseComponents.year && components.month == expenseComponents.month
            }
        }
    }
    
    func totalSpentInBreakdownRange(from expenses: [Expense]) -> Double {
        filteredExpensesForBreakdown(from: expenses).reduce(0) { $0 + $1.amount }
    }
    
    func dynamicCategoryData(from expenses: [Expense]) -> [(category: String, amount: Double, color: Color)] {
        let grouped = Dictionary(grouping: filteredExpensesForBreakdown(from: expenses), by: { $0.category })
        return grouped.map { (key, values) in
            let total = values.reduce(0) { $0 + $1.amount }
            let color = values.first?.color ?? .gray
            return (category: key, amount: total, color: color)
        }.sorted { $0.amount > $1.amount }
    }
}
