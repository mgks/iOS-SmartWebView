import Foundation
import UIKit
import WebKit

class URLHandler {
    static func handle(url: URL, webView: WKWebView) -> Bool {
        let urlString = url.absoluteString
        let context = SWVContext.shared

        // --- Handle Custom Schemes ---
        
        // Handle the new refresh scheme from the offline page.
        if url.scheme == "refresh" {
            if let appUrl = URL(string: context.appURL) {
                let request = URLRequest(url: appUrl)
                webView.load(request)
            }
            return true // We handled it.
        }
        
        // Handle FCM test notifications
        if url.scheme == "fcm" {
            if let firebasePlugin = PluginManager.shared.getPlugin(named: "Firebase") as? FirebasePlugin {
                firebasePlugin.showTestNotification()
            }
            return true // We handled it.
        }

        if urlString.starts(with: "share:") {
            let textToShare = urlString.replacingOccurrences(of: "share:", with: "")
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            if let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            return true
        }
        
        if urlString.starts(with: "print:") {
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = .general
            printInfo.jobName = "SmartWebView Print"

            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            
            // Use the webView's viewPrintFormatter for reliable printing
            printController.printFormatter = webView.viewPrintFormatter()
            
            printController.present(animated: true, completionHandler: nil)
            return true
        }
        
        if ["tel", "sms", "mailto"].contains(url.scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url); return true
        }

        if context.openExternalURLs, let host = url.host, host != context.host, !context.externalURLExceptionList.contains(host) {
            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url); return true }
        }
        
        return false // Let the WebView handle the navigation.
    }
}
