import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("customCategories") private var categories: [String] = []
    
    @State private var amount: String = "0"
    @State private var selectedCategory: String = ""
    @State private var amountScale: CGFloat = 1.0
    
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""
    
    let keypadButtons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                Spacer()
                VStack(spacing: 8) {
                    Text("How much?")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("JD")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(amount)
                            .font(.system(size: 75, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .scaleEffect(amountScale)
                    }
                    .frame(height: 90)
                }
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        
                        Button(action: {
                            triggerHaptic()
                            showAddCategoryAlert = true
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "plus")
                                Text("Add")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.blue.opacity(0.5), lineWidth: 1))
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        selectedCategory == category ?
                                        Color.white : Color.white.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        selectedCategory == category ?
                                        .black : .white.opacity(0.8)
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: selectedCategory == category ? Color.white.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
                
                VStack(spacing: 15) {
                    ForEach(keypadButtons, id: \.self) { row in
                        HStack(spacing: 15) {
                            ForEach(row, id: \.self) { button in
                                Button(action: {
                                    handleKeypadInput(button)
                                }) {
                                    Text(button)
                                        .font(.system(size: button == "⌫" ? 25 : 30, weight: .medium, design: .rounded))
                                        .frame(width: 80, height: 80)
                                        .background(Color.white.opacity(0.05))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
                
                Button(action: {
                    triggerHaptic(style: .heavy)
                    if let amountValue = Double(amount), amountValue > 0 {
                        // الترتيب الصحيح للمتغيرات حسب الموديل الجديد
                        let newExpense = Expense(category: selectedCategory, amount: amountValue)
                        context.insert(newExpense)
                        dismiss()
                    }
                }) {
                    Text("Save Expense")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(amount == "0" ? Color.white.opacity(0.1) : Color.blue)
                        .foregroundColor(amount == "0" ? .white.opacity(0.3) : .white)
                        .clipShape(Capsule())
                        .shadow(color: amount == "0" ? .clear : Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .disabled(amount == "0")
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            if selectedCategory.isEmpty {
                selectedCategory = categories.first ?? "Other 🛒"
            }
        }
        .alert("New Category", isPresented: $showAddCategoryAlert) {
            TextField("e.g. Trix 🃏", text: $newCategoryName)
            
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
            
            Button("Add") {
                if !newCategoryName.isEmpty && !categories.contains(newCategoryName) {
                    categories.insert(newCategoryName, at: 0)
                    selectedCategory = newCategoryName
                }
                newCategoryName = ""
            }
        } message: {
            Text("Add an emoji for a better look!")
        }
    }
    
    private func handleKeypadInput(_ input: String) {
        triggerHaptic()
        if input == "⌫" {
            if amount.count > 1 { amount.removeLast() } else { amount = "0" }
        } else if input == "." {
            if !amount.contains(".") { amount += "." }
        } else {
            if amount == "0" { amount = input } else if amount.count < 9 { amount += input }
        }
        withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) { amountScale = 1.1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) { amountScale = 1.0 }
        }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
