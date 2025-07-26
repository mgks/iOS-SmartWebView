import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Check if the app was launched from a notification tap.
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            if let uriString = notification["uri"] as? String, let url = URL(string: uriString) {
                // Store the URL to be loaded by the FirebasePlugin once the webview is ready.
                FirebasePlugin.launchNotificationURL = url
            }
        }
        
        return true
    }
    
    // --- Push Notification Token Handling ---
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // --- Handling Incoming Notifications ---
    
    // This method is called when a notification is tapped and the app is in the background or terminated.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Find the FirebasePlugin and tell it to handle the tap.
        if let firebasePlugin = PluginManager.shared.getPlugin(named: "Firebase") as? FirebasePlugin {
            firebasePlugin.handleNotificationTap(userInfo: userInfo)
        }
        
        completionHandler()
    }
}
