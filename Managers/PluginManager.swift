import Foundation
import WebKit

final class PluginManager {
    // Singleton instance
    static let shared = PluginManager()
    
    // A dictionary to hold all registered plugin instances.
    private var plugins: [String: PluginInterface] = [:]
    
    private init() {} // Private initializer for singleton
    
    // Registers a new plugin instance.
    func registerPlugin(_ plugin: PluginInterface) {
        guard plugins[plugin.name] == nil else {
            print("Plugin already registered: \(plugin.name)")
            return
        }
        
        plugins[plugin.name] = plugin
        print("Plugin registered: \(plugin.name)")
    }
    
    // Initializes all registered plugins.
    func initializePlugins(context: SWVContext, webView: WKWebView) {
        for plugin in plugins.values {
            plugin.initialize(context: context, webView: webView)
        }
    }
    
    // --- Event Forwarding ---
    func webViewDidFinishLoad(url: URL) {
        for plugin in plugins.values {
            plugin.webViewDidFinishLoad(url: url)
        }
    }
    
    func handleScriptMessage(message: WKScriptMessage) {
        for plugin in plugins.values {
            plugin.handleScriptMessage(message: message)
        }
    }
}
