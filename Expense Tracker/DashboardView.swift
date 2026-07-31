import SwiftUI
import Charts
import SwiftData

struct UltraPremiumDashboardView: View {
    
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    @AppStorage("monthlySalary") private var salary: Double = 1000.0
    @AppStorage("userName") private var userName: String = ""
    
    @State private var animateChart = false
    
    // --- متغير التنقل للرسم الخطي (Weekly Trend) ---
    @State private var weekOffset: Int = 0
    
    // --- فلاتر التنقل للرسم الدائري (Category Breakdown) ---
    enum BreakdownRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    @State private var selectedBreakdownRange: BreakdownRange = .month
    @State private var breakdownOffset: Int = 0

    // --- الحسابات الرياضية ---
    
    // هذا الكود الجديد بيجمع مصاريف الشهر الحالي فقط بناءً على التاريخ
        var totalSpentThisMonth: Double {
            let calendar = Calendar.current
            return expenses.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                           .reduce(0) { $0 + $1.amount }
        }
    
    var remainingBalance: Double {
        max(salary - totalSpentThisMonth, 0)
    }
    
    var safeToSpendToday: Double {
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return 0 }
        let remainingDays = range.count - calendar.component(.day, from: today) + 1
        return remainingBalance / Double(max(remainingDays, 1))
    }
    
    // --- 1. منطق الرسم الخطي الأسبوعي (Weekly Trend) مع السحب ---
    
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
    
    var dynamicWeeklyData: [(day: String, amount: Double)] {
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
    
    // --- 2. منطق الرسم الدائري (Breakdown) مع الفلاتر والسحب ---
    
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
    
    var filteredExpensesForBreakdown: [Expense] {
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
    
    var totalSpentInBreakdownRange: Double {
        filteredExpensesForBreakdown.reduce(0) { $0 + $1.amount }
    }
    
    var dynamicCategoryData: [(category: String, amount: Double, color: Color)] {
        let grouped = Dictionary(grouping: filteredExpensesForBreakdown, by: { $0.category })
        return grouped.map { (key, values) in
            let total = values.reduce(0) { $0 + $1.amount }
            let color = values.first?.color ?? .gray
            return (category: key, amount: total, color: color)
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    
                    // 1. الترحيب (Header)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            Text(userName.isEmpty ? "User" : userName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .overlay(Text(String(userName.prefix(1)).uppercased()).font(.title2.bold()).foregroundColor(.white))
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // 2. بطاقة الرصيد
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Total Spent (This Month)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Text("JD \(totalSpentThisMonth, specifier: "%.2f")")
                            .font(.system(size: 45, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text("Safe to spend today: ")
                                .foregroundColor(.gray)
                            Text("JD \(safeToSpendToday, specifier: "%.2f")")
                                .foregroundColor(safeToSpendToday > 0 ? .green : .red)
                                .bold()
                        }
                        .font(.footnote)
                    }
                    .padding(25)
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.white.opacity(0.05)))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                    .padding(.horizontal, 20)
                    
                    // --- 3. الرسم الخطي (Weekly Trend) مع السحب والأسهم فقط ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Weekly Trend 📈")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { withAnimation(.easeInOut) { weekOffset -= 1 } }) {
                                    Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8)).frame(width: 22, height: 22)
                                        .background(Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                Text(weekLabel).font(.system(size: 11, weight: .bold)).foregroundColor(.gray).frame(minWidth: 75).lineLimit(1)
                                Button(action: { withAnimation(.easeInOut) { weekOffset += 1 } }) {
                                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(weekOffset >= 0 ? .gray.opacity(0.3) : .white.opacity(0.8))
                                        .frame(width: 22, height: 22)
                                        .background(weekOffset >= 0 ? Color.clear : Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                .disabled(weekOffset >= 0)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        Chart {
                            ForEach(dynamicWeeklyData, id: \.day) { item in
                                LineMark(x: .value("Day", item.day), y: .value("Amount", animateChart ? item.amount : 0))
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                AreaMark(x: .value("Day", item.day), y: .value("Amount", animateChart ? item.amount : 0))
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(LinearGradient(colors: [Color.blue.opacity(0.4), Color.clear], startPoint: .top, endPoint: .bottom))
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis { AxisMarks(values: .automatic) { _ in AxisValueLabel().foregroundStyle(Color.gray) } }
                        .frame(height: 180)
                        .padding(.horizontal, 25)
                        .onAppear { withAnimation(.easeInOut(duration: 1.0)) { animateChart = true } }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 50 { withAnimation(.easeInOut) { weekOffset -= 1 } }
                                    else if value.translation.width < -50 { if weekOffset < 0 { withAnimation(.easeInOut) { weekOffset += 1 } } }
                                }
                        )
                    }
                    
                    // --- 4. الرسم الدائري (Category Breakdown) مع فلاتر Day / Week / Month والسحب ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Category Breakdown 🍩")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 25)
                        
                        HStack {
                            HStack(spacing: 4) {
                                ForEach(BreakdownRange.allCases, id: \.self) { range in
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            selectedBreakdownRange = range
                                            breakdownOffset = 0
                                        }
                                    }) {
                                        Text(range.rawValue)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(selectedBreakdownRange == range ? Color.blue : Color.white.opacity(0.05))
                                            .foregroundColor(selectedBreakdownRange == range ? .white : .gray)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { withAnimation(.easeInOut) { breakdownOffset -= 1 } }) {
                                    Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8)).frame(width: 22, height: 22)
                                        .background(Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                Text(breakdownLabel).font(.system(size: 11, weight: .bold)).foregroundColor(.gray).frame(minWidth: 65).lineLimit(1)
                                Button(action: { withAnimation(.easeInOut) { breakdownOffset += 1 } }) {
                                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(breakdownOffset >= 0 ? .gray.opacity(0.3) : .white.opacity(0.8))
                                        .frame(width: 22, height: 22)
                                        .background(breakdownOffset >= 0 ? Color.clear : Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                .disabled(breakdownOffset >= 0)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        VStack(spacing: 25) {
                            if dynamicCategoryData.isEmpty {
                                Text("No data for this period.")
                                    .foregroundColor(.gray)
                                    .frame(height: 150)
                            } else {
                                ZStack {
                                    Chart(dynamicCategoryData, id: \.category) { item in
                                        SectorMark(angle: .value("Amount", item.amount), innerRadius: .ratio(0.65), angularInset: 2.0)
                                            .cornerRadius(5)
                                            .foregroundStyle(item.color)
                                    }
                                    .frame(height: 200)
                                    
                                    VStack {
                                        Text("Total").font(.caption).foregroundColor(.gray)
                                        Text("JD \(totalSpentInBreakdownRange, specifier: "%.0f")").font(.title2.bold()).foregroundColor(.white)
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(dynamicCategoryData, id: \.category) { item in
                                        HStack(spacing: 10) {
                                            Circle().fill(item.color).frame(width: 12, height: 12)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.category).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.8))
                                                Text("JD \(item.amount, specifier: "%.0f")").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.5))
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white.opacity(0.05)))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 50 { withAnimation(.easeInOut) { breakdownOffset -= 1 } }
                                    else if value.translation.width < -50 { if breakdownOffset < 0 { withAnimation(.easeInOut) { breakdownOffset += 1 } } }
                                }
                        )
                    }
                    
                    // 5. الحركات الأخيرة
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                        
                        if expenses.isEmpty {
                            Text("No expenses yet. Start spending! 💸")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 25)
                        } else {
                            VStack(spacing: 15) {
                                ForEach(expenses.prefix(5)) { expense in
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle().fill(expense.color.opacity(0.2)).frame(width: 50, height: 50)
                                            Image(systemName: expense.icon).foregroundColor(expense.color).font(.title3)
                                        }
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(expense.category).font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                                            Text(expense.date, style: .time).font(.caption).foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("- JD \(expense.amount, specifier: "%.2f")").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 25)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    
                }
            }
        }
    }
}
