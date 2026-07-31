import SwiftUI
import SwiftData

@Model
class Expense {
    var id: UUID = UUID()
    var category: String
    var amount: Double
    var date: Date
    
    init(category: String, amount: Double, date: Date = .now) {
        self.category = category
        self.amount = amount
        self.date = date
    }
    
    // 1. إعطاء لون مخصص لكل تصنيف
    @Transient
    var color: Color {
        switch category {
        case "Food 🍔", "Dining Out 🍽️": return .orange
        case "Coffee ☕️": return .brown
        case "Transport 🚕", "Car 🚗": return .yellow
        case "Bills 💡", "Rent 🏠": return .blue
        case "Groceries 🛒": return .green
        case "Shopping 🛍️": return .pink
        case "Health 💊": return .red
        case "Gym 💪": return .cyan
        case "Entertainment 🎬": return .purple
        case "Education 📚": return .indigo
        case "Subscriptions 📱": return .mint
        case "Travel ✈️": return .teal
        case "Gifts 🎁": return .pink
        case "Pets 🐾": return .brown
        case "Family 👨‍👩‍👧‍👦": return .orange
        case "Savings 💰": return .green
        case "Snooker 🎱": return .teal
        default:
            // إذا المستخدم ضاف تصنيف جديد (مثل Trix)، بنعطيه لون عشوائي بس ثابت بناءً على اسمه
            return colorForUnknownCategory(name: category)
        }
    }
    
    // 2. إعطاء أيقونة مخصصة لكل تصنيف
    @Transient
    var icon: String {
        switch category {
        case "Food 🍔", "Dining Out 🍽️": return "fork.knife"
        case "Coffee ☕️": return "cup.and.saucer.fill"
        case "Transport 🚕", "Car 🚗": return "car.fill"
        case "Bills 💡": return "lightbulb.fill"
        case "Rent 🏠": return "house.fill"
        case "Groceries 🛒", "Shopping 🛍️": return "cart.fill"
        case "Health 💊": return "cross.case.fill"
        case "Gym 💪": return "dumbbell.fill"
        case "Entertainment 🎬": return "ticket.fill"
        case "Education 📚": return "book.fill"
        case "Subscriptions 📱": return "iphone"
        case "Travel ✈️": return "airplane"
        case "Gifts 🎁": return "gift.fill"
        case "Pets 🐾": return "pawprint.fill"
        case "Family 👨‍👩‍👧‍👦": return "figure.2.and.child.holdinghands"
        case "Savings 💰": return "banknote.fill"
        case "Snooker 🎱": return "circle.grid.cross.fill"
        default: return "bag.fill" // أيقونة افتراضية لأي تصنيف جديد
        }
    }
    
    // دالة ذكية لإعطاء لون ثابت لأي تصنيف جديد غير موجود بالقائمة
    private func colorForUnknownCategory(name: String) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .green, .mint, .cyan, .teal, .indigo, .red]
        // تحويل اسم التصنيف لرقم (Hash) واستخدامه لاختيار لون من المصفوفة
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}
