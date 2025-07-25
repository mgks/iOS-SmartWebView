import SwiftUI
import WebKit
import PhotosUI
import UniformTypeIdentifiers

struct WebView: UIViewRepresentable {
    let url: URL
    private let webView = WKWebView()

    // Creates the Coordinator instance that will act as a delegate for the WKWebView.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates and configures the initial WKWebView instance.
    func makeUIView(context: Context) -> WKWebView {
        let swvContext = SWVContext.shared
        let userContentController = WKUserContentController()
        
        // Register JavaScript message handlers for enabled plugins.
        // This is the bridge for JavaScript to call native Swift code.
        if swvContext.enabledPlugins.contains("Toast") { userContentController.add(context.coordinator, name: "toast") }
        if swvContext.enabledPlugins.contains("Dialog") { userContentController.add(context.coordinator, name: "dialog") }
        if swvContext.enabledPlugins.contains("Location") { userContentController.add(context.coordinator, name: "location") }
        
        webView.configuration.userContentController = userContentController
        
        // Assign the coordinator to handle webview events.
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Initialize all registered plugins, passing them the webview instance.
        PluginManager.shared.initializePlugins(context: swvContext, webView: self.webView)
        
        // Conditionally add the pull-to-refresh control based on the config.
        if swvContext.pullToRefreshEnabled {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
            webView.scrollView.addSubview(refreshControl)
            webView.scrollView.bounces = true // Must be true for the gesture to work.
        }
        
        return self.webView
    }

    // Updates the view with new data. Called when the view's state changes.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    // The Coordinator class acts as a delegate bridge between the WKWebView and SwiftUI.
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate, PHPickerViewControllerDelegate {
        var parent: WebView
        private var filePickerCompletionHandler: (([URL]?) -> Void)?

        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // --- Navigation Decisions ---
        
        // Intercept navigation actions before they are allowed.
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, URLHandler.handle(url: url, webView: webView) {
                decisionHandler(.cancel) // URL was handled natively, so cancel the webview's navigation.
                return
            }
            decisionHandler(.allow) // Let the webview proceed with the navigation.
        }
        
        // Decide what to do with a navigation response (e.g., download or view).
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if !navigationResponse.canShowMIMEType {
                decisionHandler(.download) // The content can't be shown, so treat it as a download.
            } else {
                decisionHandler(.allow) // The content can be shown in the webview.
            }
        }
        
        // Called when a download is started from a navigation response.
        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }
        
        // Called when a page has finished loading.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Stop the pull-to-refresh spinner if it's active.
            if let refreshControl = webView.scrollView.subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl {
                refreshControl.endRefreshing()
            }
            // Notify the PluginManager that the page has loaded.
            if let url = webView.url {
                PluginManager.shared.webViewDidFinishLoad(url: url)
            }
        }
        
        // --- JS -> Native Communication ---
        
        // Called when JavaScript posts a message to a registered handler.
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            PluginManager.shared.handleScriptMessage(message: message)
        }
        
        // --- UI Actions ---
        
        // The action triggered by the pull-to-refresh control.
        @objc func handleRefresh() {
            parent.webView.reload()
        }
        
        // Called when an <input type="file"> is clicked in the web page.
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            guard SWVContext.shared.fileUploadsEnabled else { completionHandler(nil); return }
            self.filePickerCompletionHandler = completionHandler
            
            var config = PHPickerConfiguration()
            config.selectionLimit = SWVContext.shared.multipleUploadsEnabled && parameters.allowsMultipleSelection ? 0 : 1
            config.filter = .any(of: [.images, .videos])
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            if let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
                rootVC.present(picker, animated: true)
            }
        }
        
        // Delegate method for when the user finishes selecting items in the photo picker.
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { filePickerCompletionHandler?(nil); return }
            
            var urls: [URL] = []
            let group = DispatchGroup() // Use a DispatchGroup to wait for all files to be processed.
            
            for result in results {
                group.enter()
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                    defer { group.leave() }
                    if let url = url {
                        // Copy the file to a temporary directory so the webview has permission to access it.
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(url.pathExtension)
                        try? FileManager.default.copyItem(at: url, to: tempURL)
                        urls.append(tempURL)
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.filePickerCompletionHandler?(urls)
            }
        }
    }
}

// Extension to handle download delegate methods.
extension WebView.Coordinator: WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent(suggestedFilename)
        completionHandler(fileURL)
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        print("Download finished.")
        // A good place to trigger a "Download Complete" toast.
    }
}
