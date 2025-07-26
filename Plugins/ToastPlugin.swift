import Foundation
import WebKit
import UIKit

class ToastPlugin: PluginInterface {
    var name: String = "Toast"
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
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Slightly more solid
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium) // A bit bolder
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 18 // More rounded for a "pill" shape
        toastLabel.clipsToBounds = true
        
        // Add padding inside the label
        toastLabel.numberOfLines = 0 // Allow multiple lines
        let horizontalPadding: CGFloat = 20.0
        let verticalPadding: CGFloat = 10.0
        
        window.addSubview(toastLabel)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -60), // A bit higher
            // Make the width dynamic but with a max limit
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, constant: -40),
            // REMOVE fixed height, let it be dynamic based on text
        ])
        
        // Create an "inset" version of the label for padding
        let toastContainer = UIView()
        toastContainer.backgroundColor = .clear
        toastContainer.addSubview(toastLabel)
        window.addSubview(toastContainer)

        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Pin toastLabel to its container with padding
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: verticalPadding),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -verticalPadding),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: horizontalPadding),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -horizontalPadding),

            // Position the container on the screen
            toastContainer.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            toastContainer.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, constant: -40),
        ])

        // We now animate the container, not the label directly
        toastContainer.layer.cornerRadius = (toastLabel.font.pointSize + verticalPadding * 2) / 2
        toastContainer.layer.masksToBounds = true
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastContainer.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
            toastContainer.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.5, animations: { toastContainer.alpha = 0.0 }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
