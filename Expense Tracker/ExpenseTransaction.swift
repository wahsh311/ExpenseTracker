import Foundation
import SwiftUI

struct ExpenseTransaction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let amount: Double
    let time: String
    let color: Color
}
