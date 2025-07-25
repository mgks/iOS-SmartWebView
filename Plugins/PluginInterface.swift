import Foundation
import WebKit

// The contract that all plugins must conform to.
protocol PluginInterface {
    // A unique name for the plugin.
    var name: String { get }
    
    // Called once to initialize the plugin with necessary contexts.
    func initialize(context: SWVContext, webView: WKWebView)
    
    // --- WebView Lifecycle Events ---
    func webViewDidFinishLoad(url: URL)
    
    // --- JavaScript Communication ---
    func handleScriptMessage(message: WKScriptMessage)
}

// Provide default empty implementations. This makes the methods "optional"
// for any plugin that doesn't need to implement them.
extension PluginInterface {
    func initialize(context: SWVContext, webView: WKWebView) {}
    func webViewDidFinishLoad(url: URL) {}
    func handleScriptMessage(message: WKScriptMessage) {}
}
