import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Expense_TrackerApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true

  var body: some Scene {
    WindowGroup {
      NavigationView {
          if isFirstLaunch {
                          // إذا أول مرة، بتطلع شاشة التهيئة
                        OnboardingView()
                      } else {
                          // إذا مش أول مرة، بيروح عالـ TabBar أو الشاشة الرئيسية
                          MainView()
                      }
      }
    }
    .modelContainer(for: Expense.self)
  }
}
