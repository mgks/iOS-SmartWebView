import Foundation
import WebKit
import UIKit

class ToastPlugin: PluginInterface {
    var name: String = "ToastPlugin"
    private weak var webView: WKWebView?

    static func register() {
        PluginManager.shared.registerPlugin(ToastPlugin())
    }
    
    func initialize(context: SWVContext, webView: WKWebView) {
        self.webView = webView
    }
    
    func handleScriptMessage(message: WKScriptMessage) {
        if message.name == "toast", let body = message.body as? String {
            showToast(message: body)
        }
    }
    
    func webViewDidFinishLoad(url: URL) {
        let script = """
            if (!window.Toast) {
                window.Toast = {
                    show: function(message) {
                        if (window.webkit && window.webkit.messageHandlers.toast) {
                            window.webkit.messageHandlers.toast.postMessage(message);
                        }
                    }
                };
                console.log('Toast JavaScript interface injected.');
            }
        """
        
        DispatchQueue.main.async {
            // First, inject the Toast object.
            self.webView?.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Error injecting Toast JS: \(error.localizedDescription)")
                    return
                }
                
                // Now that the injection is complete, run the test if in debug mode.
                if SWVContext.shared.debugMode {
                    let testScript = "setTimeout(() => window.Toast.show('Hello from iOS! (Debug)'), 2000);"
                    self.webView?.evaluateJavaScript(testScript, completionHandler: nil)
                }
            }
        }
    }

    private func showToast(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        window.addSubview(toastLabel)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.5, animations: { toastLabel.alpha = 1.0 }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, animations: { toastLabel.alpha = 0.0 }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
