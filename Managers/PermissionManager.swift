import Foundation
import UserNotifications
import CoreLocation
import UIKit

// Manages all native permission requests for the application.
class PermissionManager: NSObject { // Add CLLocationManagerDelegate
    
    // Use a singleton pattern to be accessible from anywhere and manage delegate callbacks.
    static let shared = PermissionManager()
    
    private override init() {
        super.init()
    }
    
    // Central function to request all permissions listed in swv.properties on launch.
    func requestInitialPermissions() {
        let context = SWVContext.shared
        
        if context.permissionsOnLaunch.contains("NOTIFICATIONS") {
            requestNotificationPermission()
        }
        
        if context.permissionsOnLaunch.contains("LOCATION") {
            // We just need to trigger the LocationPlugin to ask.
            // A simple way is to instantiate its manager so it can request.
            if let locationPlugin = PluginManager.shared.getPlugin(named: "Location") as? LocationPlugin {
                print("Triggering initial location permission request via LocationPlugin.")
                locationPlugin.requestInitialPermission()
            }
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

    // --- Delegate Method ---
    // This delegate method is now handled here, but it doesn't need to do anything
    // as the LocationPlugin will check the status again when it's used.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("PermissionManager: Location authorization status changed to: \(manager.authorizationStatus.rawValue)")
    }
}
