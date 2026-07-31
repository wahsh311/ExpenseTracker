
import SwiftUI

struct UltraPremiumOnboardingView: View {
    // المتغيرات اللي رح تنحفظ في ذاكرة الجهاز
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("monthlySalary") private var salary: Double = 1000.0
    @AppStorage("customCategories") private var selectedCategories: [String] = ["Food 🍔", "Transport 🚕", "Coffee ☕️", "Bills 💡"]
    
    @State private var currentStep = 0
    @State private var newCategory: String = ""
    
    // قائمة بكل التصنيفات المقترحة اللي بتخطر عالبال
    @State private var availableCategories: [String] = [
        "Food 🍔", "Coffee ☕️", "Transport 🚕", "Bills 💡",
        "Groceries 🛒", "Shopping 🛍️", "Health 💊", "Gym 💪",
        "Entertainment 🎬", "Education 📚", "Rent 🏠", "Subscriptions 📱",
        "Travel ✈️", "Gifts 🎁", "Pets 🐾", "Family 👨‍👩‍👧‍👦",
        "Car 🚗", "Dining Out 🍽️", "Savings 💰", "Snooker 🎱"
    ]
    
    // ترتيب الأزرار كشبكة من عمودين
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08).edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentStep) {
                
                // --- الصفحة الأولى: الاسم والراتب ---
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Welcome to\nExpense Tracker")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // حقل الاسم
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's your name?").foregroundColor(.gray)
                            TextField("e.g. Abdelqader", text: $userName)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        
                        // حقل الراتب
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
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { currentStep = 1 }
                        hideKeyboard()
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
                
                // --- الصفحة الثانية: التصنيفات المتطورة ---
                VStack(spacing: 20) {
                    Text("Select Categories")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Tap to select what you usually spend on")
                        .foregroundColor(.gray)
                    
                    // إضافة تصنيف مخصص
                    HStack {
                        TextField("Missing something? (e.g. Trix 🃏)", text: $newCategory)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        
                        Button(action: {
                            if !newCategory.isEmpty && !availableCategories.contains(newCategory) {
                                // إضافة التصنيف الجديد للقائمة واختياره فوراً
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
                    
                    // شبكة التصنيفات (Grid)
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
                                        .background(
                                            isSelected ? Color.blue : Color.white.opacity(0.05)
                                        )
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    Button(action: {
                        // إغلاق شاشة الدخول للأبد والانتقال للـ Dashboard
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
            hideKeyboard()
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// هذا الكود بيسمح لـ AppStorage بحفظ مصفوفة النصوص (التصنيفات) في ذاكرة الجهاز
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

