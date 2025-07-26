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
            // Use a small delay to ensure the web page's own scripts have finished running.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.injectPlaygroundUI()
                self.runDiagnostics()
            }
        }
    }
    
    // Runs automated tests/actions on launch.
    private func runDiagnostics() {
        if let firebasePlugin = PluginManager.shared.getPlugin(named: "Firebase") as? FirebasePlugin {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                firebasePlugin.showTestNotification()
            }
        }
    }
    
    // Injects the floating UI into the web page.
    private func injectPlaygroundUI() {
        // Create a JSON object of active plugins.
        let pluginStatus = """
        {
          "Toast": \(PluginManager.shared.getPlugin(named: "Toast") != nil),
          "Dialog": \(PluginManager.shared.getPlugin(named: "Dialog") != nil),
          "Location": \(PluginManager.shared.getPlugin(named: "Location") != nil),
          "Firebase": \(PluginManager.shared.getPlugin(named: "Firebase") != nil)
        }
        """
        
        // This JavaScript is a direct equivalent of the Android Playground's UI injector.
        let script = """
        function createDemoUI(pluginStatus) {
          if (document.getElementById('swv-pg-container-999')) return;
          const css = `
            #swv-pg-container-999 { all: initial; position: fixed; bottom: 15px; right: 15px; z-index: 2147483647; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
            #swv-pg-toggle-999 { all: initial; width: 60px; height: 60px; background-color: #007aff; color: white; border-radius: 50%; border: none; font-size: 28px; line-height: 60px; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.2); cursor: pointer; }
            #swv-pg-panel-999 { all: initial; display: none; position: absolute; bottom: 75px; right: 0; width: 280px; background-color: rgba(20,20,20,0.9); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); color: white; border-radius: 12px; padding: 15px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); }
            #swv-pg-panel-999.visible { display: block; }
            #swv-pg-panel-999 h4 { all: initial; margin: 5px 0 15px; text-align: center; font-weight: bold; font-size: 16px; color: white; display: block; }
            .swv-pg-btn-999 { all: initial; display: block; width: 94%; padding: 12px 3%; margin: 6px 0; background-color: #555; color: white; border: none; border-radius: 6px; text-align: left; cursor: pointer; font-size: 14px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
            .swv-pg-btn-999:disabled { background-color: #444; color: #888; cursor: not-allowed; }
          `;
          const style = document.createElement('style'); style.textContent = css; document.head.appendChild(style);
          const container = document.createElement('div'); container.id = 'swv-pg-container-999';
          const panel = document.createElement('div'); panel.id = 'swv-pg-panel-999'; panel.innerHTML = '<h4>Plugin Playground</h4>';
          const toggleBtn = document.createElement('button'); toggleBtn.id = 'swv-pg-toggle-999'; toggleBtn.innerHTML = '⚙';
          toggleBtn.onclick = () => { panel.classList.toggle('visible'); };
          
          const buttons = [
            { text: 'Show Toast', action: `window.Toast.show('Hello from Playground!')`, plugin: 'Toast' },
            { text: 'Show Dialog', action: `window.Dialog.show({ title: 'Test', message: 'This is a native dialog.' }, res => console.log(res))`, plugin: 'Dialog' },
            { text: 'Get Location', action: `window.SWVLocation.getCurrentPosition((lat, lng, err) => alert('Lat: ' + lat + ', Lng: ' + lng + ', Err: ' + err))`, plugin: 'Location' }
          ];
          
          buttons.forEach(btnInfo => {
            const button = document.createElement('button');
            button.className = 'swv-pg-btn-999';
            button.innerText = btnInfo.text;
            if (pluginStatus[btnInfo.plugin]) {
              button.onclick = () => { try { eval(btnInfo.action); } catch(e) { alert('Error: ' + e.message); } };
            } else {
              button.disabled = true;
              button.innerText += ' (Disabled)';
            }
            panel.appendChild(button);
          });
          
          container.appendChild(panel); container.appendChild(toggleBtn); document.body.appendChild(container);
        }
        createDemoUI(\(pluginStatus));
        """
        
        PluginManager.shared.evaluateJavaScript(script)
    }
}
