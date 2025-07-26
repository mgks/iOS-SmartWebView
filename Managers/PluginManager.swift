import Foundation
import WebKit

final class PluginManager {
    static let shared = PluginManager()
    private var plugins: [String: PluginInterface] = [:]
    
    // Store a reference to the webView after initialization.
    private weak var webView: WKWebView?

    private init() {}
    
    func registerPlugin(_ plugin: PluginInterface) {
        guard plugins[plugin.name] == nil else { return }
        plugins[plugin.name] = plugin
        print("Plugin registered: \(plugin.name)")
    }
    
    // Allows other parts of the app to get a specific plugin instance.
    func getPlugin(named name: String) -> PluginInterface? {
        return plugins[name]
    }
    
    // A convenient way to evaluate JavaScript on the main webView.
    func evaluateJavaScript(_ script: String) {
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    func initializePlugins(context: SWVContext, webView: WKWebView) {
        self.webView = webView // Store the webView reference.
        for plugin in plugins.values {
            plugin.initialize(context: context, webView: webView)
        }
    }
    
    // --- Event Forwarding ---
    func webViewDidFinishLoad(url: URL) { for plugin in plugins.values { plugin.webViewDidFinishLoad(url: url) } }
    func handleScriptMessage(message: WKScriptMessage) {
        // message.name is "toast", "dialog", "location" etc.
        // Our plugin names are "Toast", "Dialog", "Location".
        // We need to match them, case-insensitively for safety.
        let handlerName = message.name.lowercased()
        
        for plugin in plugins.values {
            // e.g. does "Toast".lowercased() == "toast" ?
            if plugin.name.lowercased() == handlerName {
                plugin.handleScriptMessage(message: message)
                return // Stop after finding the correct handler
            }
        }
    }
}
