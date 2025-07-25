import SwiftUI

struct ContentView: View {
    // Get the initial URL to load directly from our shared context singleton.
    private let initialURL = SWVContext.shared.initialURL

    var body: some View {
        // Use a ZStack to layer views. This will be useful later for overlays
        // like a splash screen or security features.
        ZStack {
            if let url = initialURL {
                WebView(url: url)
                    // This makes the WebView ignore the safe areas (like the notch),
                    // allowing it to fill the entire screen for an immersive experience.
                    .ignoresSafeArea()
            } else {
                // Fallback view if the initial URL couldn't be determined.
                // This might happen if swv.properties is malformed.
                Text("Error: Initial URL could not be determined.")
            }
        }
    }
}

// This is a special macro for Xcode Previews. It allows you to see
// your UI changes in the canvas without having to build and run the app.
// It is essential for rapid UI development.
#Preview {
    ContentView()
}
