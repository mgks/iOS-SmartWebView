import Foundation
import WebKit

class Playground: PluginInterface {
    var name: String = "Playground"
    private weak var webView: WKWebView?
    
    static func register() {
        PluginManager.shared.registerPlugin(Playground())
    }
    
    func initialize(context: SWVContext, webView: WKWebView) {
        self.webView = webView
    }
    
    func webViewDidFinishLoad(url: URL) {
        let context = SWVContext.shared
        if context.playgroundEnabled && context.debugMode {
            injectPlaygroundUI()
        }
    }
    
    private func injectPlaygroundUI() {
        let script = """
            // Your JavaScript for the playground UI goes here.
            // For now, we'll just log to the console.
            console.log('Playground is active!');
            
            // REMOVE THE TOAST TEST FROM HERE
            // if (window.Toast) {
            //     setTimeout(() => window.Toast.show('Hello from iOS! (Debug)'), 2000);
            // }
        """
        
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
