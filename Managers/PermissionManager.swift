import Foundation
import UserNotifications
import CoreLocation
import UIKit

// Manages all native permission requests for the application.
class PermissionManager: NSObject, CLLocationManagerDelegate {
    
    // Use a singleton pattern to be accessible from anywhere and manage delegate callbacks.
    static let shared = PermissionManager()
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Central function to request all permissions listed in swv.properties on launch.
    func requestInitialPermissions() {
        let context = SWVContext.shared
        
        if context.permissionsOnLaunch.contains("NOTIFICATIONS") {
            requestNotificationPermission()
        }
        
        if context.permissionsOnLaunch.contains("LOCATION") {
            // This just checks the status; the LocationPlugin will trigger the actual request.
            // This ensures the delegate is ready.
            print("Location permission will be requested on-demand by the LocationPlugin.")
        }
    }
    
    // --- Notification Permissions ---
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                    // Once permission is granted, register for remote notifications.
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
}
