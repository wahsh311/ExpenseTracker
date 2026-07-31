import SwiftUI
import SwiftData

struct CSVFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @AppStorage("monthlySalary") private var salary: Double = 1000.0
    @AppStorage("fixedExpenses") private var fixedExpenses: Double = 0.0
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("customCategories") private var categories: [String] = []
    
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    @State private var salaryInput: String = ""
    @State private var fixedExpensesInput: String = ""
    @State private var showDeleteAlert = false
    @FocusState private var isKeyboardFocused: Bool
    
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""
    
    @State private var csvToShare: CSVFile? = nil

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { isKeyboardFocused = false }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {
                    
                    HStack {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                                .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Text(String(userName.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 5) {
                            TextField("Your Name", text: $userName)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .focused($isKeyboardFocused)
                            
                            Text("iOS Developer")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Budget Configuration")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Monthly Salary")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("JD").foregroundColor(.gray)
                                    TextField("1000", text: $salaryInput)
                                        .keyboardType(.decimalPad)
                                        .focused($isKeyboardFocused)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .frame(width: 80)
                                        .onChange(of: salaryInput) { newValue in
                                            if let newSalary = Double(newValue) { salary = newSalary }
                                        }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                            }
                            .padding(20)
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Text("Fixed Bills")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("JD").foregroundColor(.gray)
                                    TextField("0", text: $fixedExpensesInput)
                                        .keyboardType(.decimalPad)
                                        .focused($isKeyboardFocused)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .frame(width: 80)
                                        .onChange(of: fixedExpensesInput) { newValue in
                                            if let newFixed = Double(newValue) { fixedExpenses = newFixed }
                                        }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                            }
                            .padding(20)
                        }
                        .glassCard(cornerRadius: 25)
                        .padding(.horizontal, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Manage Categories")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                triggerHaptic(style: .medium)
                                showAddCategoryAlert = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        VStack(spacing: 0) {
                            if categories.isEmpty {
                                Text("No categories added.")
                                    .foregroundColor(.gray)
                                    .padding(20)
                            } else {
                                ForEach(categories, id: \.self) { category in
                                    HStack {
                                        Text(category)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button(action: { deleteCategory(category) }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.red.opacity(0.8))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 20)
                                    
                                    if category != categories.last {
                                        Divider()
                                            .background(Color.white.opacity(0.1))
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .glassCard(cornerRadius: 25)
                        .padding(.horizontal, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Data Management")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                        
                        VStack(spacing: 0) {
                            Button(action: { exportToCSV() }) {
                                HStack {
                                    ZStack {
                                        Circle().fill(Color.green.opacity(0.2)).frame(width: 40, height: 40)
                                        Image(systemName: "square.and.arrow.up.fill").foregroundColor(.green)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Export to CSV")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Save your expenses as an Excel file")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5)).font(.caption)
                                }
                                .padding(20)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                triggerHaptic(style: .medium)
                                showDeleteAlert = true
                            }) {
                                HStack {
                                    ZStack {
                                        Circle().fill(Color.red.opacity(0.2)).frame(width: 40, height: 40)
                                        Image(systemName: "trash.fill").foregroundColor(.red)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Erase All Data")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.red)
                                        Text("Permanently delete all expenses")
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.6))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.red.opacity(0.5)).font(.caption)
                                }
                                .padding(20)
                            }
                        }
                        .glassCard(cornerRadius: 25)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .onAppear {
            salaryInput = String(format: "%.0f", salary)
            fixedExpensesInput = String(format: "%.0f", fixedExpenses)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Erase All Expenses?"),
                message: Text("Are you sure you want to delete all your expenses? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete All")) {
                    deleteAllExpenses()
                },
                secondaryButton: .cancel()
            )
        }
        .alert("New Category", isPresented: $showAddCategoryAlert) {
            TextField("e.g. Games 🎮", text: $newCategoryName)
            Button("Cancel", role: .cancel) { newCategoryName = "" }
            Button("Add") {
                if !newCategoryName.isEmpty && !categories.contains(newCategoryName) {
                    withAnimation { categories.append(newCategoryName) }
                }
                newCategoryName = ""
            }
        }
        .sheet(item: $csvToShare) { csv in
            ShareSheet(activityItems: [csv.url])
        }
    }
    
    private func exportToCSV() {
        triggerHaptic(style: .medium)
        
        var csvText = "Date,Category,Amount (JD)\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for expense in expenses {
            let dateString = formatter.string(from: expense.date)
            let safeCategory = expense.category.replacingOccurrences(of: ",", with: " ")
            let amountString = String(format: "%.2f", expense.amount)
            
            csvText.append("\(dateString),\(safeCategory),\(amountString)\n")
        }
        
        let fileName = "MyExpenses.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            csvToShare = CSVFile(url: path)
        } catch {
            print("Failed to create CSV file: \(error.localizedDescription)")
        }
    }
    
    private func deleteCategory(_ category: String) {
        triggerHaptic(style: .medium)
        withAnimation { categories.removeAll { $0 == category } }
    }
    
    private func deleteAllExpenses() {
        triggerHaptic(style: .heavy)
        for expense in expenses { context.delete(expense) }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
