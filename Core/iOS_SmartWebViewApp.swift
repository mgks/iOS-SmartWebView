import SwiftUI

@main
struct iOS_SmartWebViewApp: App {
    
    // This connects our AppDelegate to the SwiftUI app lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        registerPlugins()
        PermissionManager.shared.requestInitialPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func registerPlugins() {
        let context = SWVContext.shared
        
        if context.enabledPlugins.contains("Toast") { ToastPlugin.register() }
        if context.enabledPlugins.contains("Playground") { Playground.register() }
        if context.enabledPlugins.contains("Dialog") { DialogPlugin.register() }
        if context.enabledPlugins.contains("Location") { LocationPlugin.register() }
        if context.enabledPlugins.contains("Rating") { RatingPlugin.register() }
        if context.enabledPlugins.contains("Firebase"){ FirebasePlugin.register() }
    }
}
