import SwiftUI

struct OnboardingView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("monthlySalary") private var salary: Double = 1000.0
    @AppStorage("fixedExpenses") private var fixedExpenses: Double = 0.0
    @AppStorage("customCategories") private var selectedCategories: [String] = ["Food 🍔", "Transport 🚕", "Coffee ☕️", "Bills 💡"]
    
    @State private var currentStep = 0
    @State private var newCategory: String = ""
    @FocusState private var isKeyboardFocused: Bool
    
    @State private var availableCategories: [String] = [
        "Food 🍔", "Coffee ☕️", "Transport 🚕", "Bills 💡",
        "Groceries 🛒", "Shopping 🛍️", "Health 💊", "Gym 💪",
        "Entertainment 🎬", "Education 📚", "Rent 🏠", "Subscriptions 📱",
        "Travel ✈️", "Gifts 🎁", "Pets 🐾", "Family 👨‍👩‍👧‍👦",
        "Car 🚗", "Dining Out 🍽️", "Savings 💰", "Snooker 🎱"
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08).edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentStep) {
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Welcome to\nExpense Tracker")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's your name?").foregroundColor(.gray)
                            TextField("e.g. Abdelqader", text: $userName)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .focused($isKeyboardFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Salary (JD)").foregroundColor(.gray)
                            TextField("1000", value: $salary, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .focused($isKeyboardFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fixed Bills (Rent, Subs, etc.) - JD").foregroundColor(.gray)
                            TextField("0", value: $fixedExpenses, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .focused($isKeyboardFocused)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { currentStep = 1 }
                        isKeyboardFocused = false
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(userName.isEmpty ? .gray : .white)
                            .cornerRadius(15)
                    }
                    .disabled(userName.isEmpty)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
                .tag(0)
                
                VStack(spacing: 20) {
                    Text("Select Categories")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Tap to select what you usually spend on")
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("Missing something? (e.g. Trix 🃏)", text: $newCategory)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .focused($isKeyboardFocused)
                        
                        Button(action: {
                            if !newCategory.isEmpty && !availableCategories.contains(newCategory) {
                                availableCategories.insert(newCategory, at: 0)
                                selectedCategories.append(newCategory)
                                newCategory = ""
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(availableCategories, id: \.self) { category in
                                let isSelected = selectedCategories.contains(category)
                                
                                Button(action: {
                                    triggerHaptic()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if isSelected {
                                            selectedCategories.removeAll(where: { $0 == category })
                                        } else {
                                            selectedCategories.append(category)
                                        }
                                    }
                                }) {
                                    Text(category)
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(isSelected ? Color.blue : Color.white.opacity(0.05))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        withAnimation { isFirstLaunch = false }
                    }) {
                        Text("Start Tracking")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCategories.isEmpty ? Color.gray.opacity(0.3) : Color.green)
                            .foregroundColor(selectedCategories.isEmpty ? .gray : .white)
                            .cornerRadius(15)
                            .shadow(color: selectedCategories.isEmpty ? .clear : .green.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(selectedCategories.isEmpty)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onTapGesture {
            isKeyboardFocused = false
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else { return "[]" }
        return result
    }
}
