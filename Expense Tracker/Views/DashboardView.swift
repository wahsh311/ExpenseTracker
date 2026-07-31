import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @StateObject private var viewModel = DashboardViewModel()
    
    @AppStorage("userName") private var userName: String = ""
    @State private var animateChart = false

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
                        
                        Text("JD \(viewModel.totalSpentThisMonth(from: expenses), specifier: "%.2f")")
                            .font(.system(size: 45, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text("Safe to spend today: ")
                                .foregroundColor(.gray)
                            Text("JD \(viewModel.safeToSpendToday(from: expenses), specifier: "%.2f")")
                                .foregroundColor(viewModel.safeToSpendToday(from: expenses) > 0 ? .green : .red)
                                .bold()
                        }
                        .font(.footnote)
                    }
                    .padding(25)
                    .glassCard(cornerRadius: 30) // 👈 تطبيق الزجاج بسطر واحد
                    .padding(.horizontal, 20)
                    
                    // 3. الرسم الخطي (Weekly Trend)
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Weekly Trend 📈")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { withAnimation(.easeInOut) { viewModel.weekOffset -= 1 } }) {
                                    Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8)).frame(width: 22, height: 22)
                                        .background(Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                Text(viewModel.weekLabel).font(.system(size: 11, weight: .bold)).foregroundColor(.gray).frame(minWidth: 75).lineLimit(1)
                                Button(action: { withAnimation(.easeInOut) { viewModel.weekOffset += 1 } }) {
                                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(viewModel.weekOffset >= 0 ? .gray.opacity(0.3) : .white.opacity(0.8))
                                        .frame(width: 22, height: 22)
                                        .background(viewModel.weekOffset >= 0 ? Color.clear : Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                .disabled(viewModel.weekOffset >= 0)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        Chart {
                            ForEach(viewModel.dynamicWeeklyData(from: expenses), id: \.day) { item in
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
                                    if value.translation.width > 50 { withAnimation(.easeInOut) { viewModel.weekOffset -= 1 } }
                                    else if value.translation.width < -50 { if viewModel.weekOffset < 0 { withAnimation(.easeInOut) { viewModel.weekOffset += 1 } } }
                                }
                        )
                    }
                    
                    // 4. الرسم الدائري (Category Breakdown)
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
                                            viewModel.selectedBreakdownRange = range
                                            viewModel.breakdownOffset = 0
                                        }
                                    }) {
                                        Text(range.rawValue)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(viewModel.selectedBreakdownRange == range ? Color.blue : Color.white.opacity(0.05))
                                            .foregroundColor(viewModel.selectedBreakdownRange == range ? .white : .gray)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { withAnimation(.easeInOut) { viewModel.breakdownOffset -= 1 } }) {
                                    Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8)).frame(width: 22, height: 22)
                                        .background(Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                Text(viewModel.breakdownLabel).font(.system(size: 11, weight: .bold)).foregroundColor(.gray).frame(minWidth: 65).lineLimit(1)
                                Button(action: { withAnimation(.easeInOut) { viewModel.breakdownOffset += 1 } }) {
                                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                                        .foregroundColor(viewModel.breakdownOffset >= 0 ? .gray.opacity(0.3) : .white.opacity(0.8))
                                        .frame(width: 22, height: 22)
                                        .background(viewModel.breakdownOffset >= 0 ? Color.clear : Color.white.opacity(0.1)).clipShape(Circle())
                                }
                                .disabled(viewModel.breakdownOffset >= 0)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        VStack(spacing: 25) {
                            if viewModel.dynamicCategoryData(from: expenses).isEmpty {
                                Text("No data for this period.")
                                    .foregroundColor(.gray)
                                    .frame(height: 150)
                            } else {
                                ZStack {
                                    Chart(viewModel.dynamicCategoryData(from: expenses), id: \.category) { item in
                                        SectorMark(angle: .value("Amount", item.amount), innerRadius: .ratio(0.65), angularInset: 2.0)
                                            .cornerRadius(5)
                                            .foregroundStyle(item.color)
                                    }
                                    .frame(height: 200)
                                    
                                    VStack {
                                        Text("Total").font(.caption).foregroundColor(.gray)
                                        Text("JD \(viewModel.totalSpentInBreakdownRange(from: expenses), specifier: "%.0f")").font(.title2.bold()).foregroundColor(.white)
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(viewModel.dynamicCategoryData(from: expenses), id: \.category) { item in
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
                        .glassCard(cornerRadius: 30) // 👈 تطبيق الزجاج بسطر واحد
                        .padding(.horizontal, 20)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 50 { withAnimation(.easeInOut) { viewModel.breakdownOffset -= 1 } }
                                    else if value.translation.width < -50 { if viewModel.breakdownOffset < 0 { withAnimation(.easeInOut) { viewModel.breakdownOffset += 1 } } }
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
