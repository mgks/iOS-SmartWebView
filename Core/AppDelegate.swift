import UIKit
import FirebaseCore
import FirebaseMessaging

// The AppDelegate is the traditional entry point for handling application-level events.
// We use it here specifically for push notification setup and callbacks.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // --- Firebase Configuration ---
        // This must be called for Firebase services to work.
        FirebaseApp.configure()
        
        // --- Push Notification Delegate Setup ---
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // --- Push Notification Token Handling ---
    
    // This function is called when a new FCM registration token is generated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
        // Here, you would typically send this token to your server.
        // For now, we'll just log it.
    }
    
    // Called when the app successfully registers with Apple Push Notification service (APNs).
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass the APNs token to Firebase Messaging.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Called if registration with APNs fails.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
