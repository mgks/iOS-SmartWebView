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

        if urlString.starts(with: "share:") {
            let textToShare = urlString.replacingOccurrences(of: "share:", with: "")
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            if let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            return true
        }
        
        // ... (rest of the file is the same)
        if ["tel", "sms", "mailto"].contains(url.scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url); return true
        }
        if urlString.starts(with: "print:") {
            let printController = UIPrintInteractionController.shared; let printInfo = UIPrintInfo(dictionary:nil); printInfo.outputType = .general; printInfo.jobName = "SmartWebView Print"; printController.printInfo = printInfo; printController.printingItem = webView; printController.present(animated: true); return true
        }
        if context.openExternalURLs, let host = url.host, host != context.host, !context.externalURLExceptionList.contains(host) {
            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url); return true }
        }
        
        return false // Let the WebView handle the navigation.
    }
}
