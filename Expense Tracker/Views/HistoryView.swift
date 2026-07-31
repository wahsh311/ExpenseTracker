import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredExpenses: [Expense] {
        if searchText.isEmpty {
            return expenses
        } else {
            return expenses.filter { expense in
                expense.category.localizedCaseInsensitiveContains(searchText) ||
                String(expense.amount).contains(searchText)
            }
        }
    }
    
    var groupedExpenses: [(month: String, expenses: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let grouped = Dictionary(grouping: filteredExpenses) { formatter.string(from: $0.date) }
        
        return grouped.map { (month: $0.key, expenses: $0.value) }
            .sorted { (group1, group2) in
                let date1 = group1.expenses.first?.date ?? Date.distantPast
                let date2 = group2.expenses.first?.date ?? Date.distantPast
                return date1 > date2
            }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { isSearchFocused = false }
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("History")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search category or amount...", text: $searchText)
                        .foregroundColor(.white)
                        .disableAutocorrection(true)
                        .focused($isSearchFocused)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            withAnimation {
                                searchText = ""
                                isSearchFocused = true
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
                
                if filteredExpenses.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(searchText.isEmpty ? "No expenses yet.\nStart tracking! 💸" : "No results found for '\(searchText)'")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List {
                        ForEach(groupedExpenses, id: \.month) { group in
                            Section {
                                ForEach(group.expenses) { expense in
                                    ExpenseRowItem(expense: expense)
                                        .listRowBackground(Color.white.opacity(0.05))
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteExpense(expense)
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                            .tint(.red)
                                        }
                                }
                            } header: {
                                Text(group.month)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 5)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .simultaneousGesture(DragGesture().onChanged { _ in
                        isSearchFocused = false
                    })
                }
            }
        }
    }
    
    private func deleteExpense(_ expense: Expense) {
        triggerHaptic(style: .medium)
        context.delete(expense)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct ExpenseRowItem: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(expense.color.opacity(0.2)).frame(width: 50, height: 50)
                Image(systemName: expense.icon).foregroundColor(expense.color).font(.title3)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(expense.category).font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                Text(expense.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Text("- JD \(expense.amount, specifier: "%.2f")")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}
