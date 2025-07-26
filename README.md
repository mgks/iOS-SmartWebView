# iOS Smart WebView

<p>
  <a href="#features"><img alt="Variant" src="https://img.shields.io/badge/language-Swift-orange.svg"></a>
  <a href="https://github.com/mgks/iOS-SmartWebView/releases"><img alt="Releases" src="https://img.shields.io/github/v/release/mgks/iOS-SmartWebView"></a>
  <a href="https://github.com/mgks/iOS-SmartWebView/blob/master/LICENSE"><img alt="GitHub License" src="https://img.shields.io/github/license/mgks/iOS-SmartWebView"></a>
</p>

**iOS Smart WebView** is a modern, open-source solution for building advanced hybrid iOS apps, designed as a direct parallel to the already established [Android Smart WebView](https://github.com/mgks/Android-SmartWebView) project. It allows you to effortlessly extend your app with plugins, native features, and a customizable UI, all configured from a single properties file.

**[DOCUMENTATION](https://docs.mgks.dev/smart-webview/)** | **[GET PREMIUM PLUGINS](https://github.com/sponsors/mgks/sponsorships?sponsor=mgks&tier_id=468838)** | **[ISSUES](https://github.com/mgks/iOS-SmartWebView/issues)**

## Core Features

*   **Plugin Architecture:** Extend app functionality with self-registering plugins written in Swift. See `PluginInterface.swift`, `PluginManager.swift`, and existing plugins in `/Plugins/` for details.
*   **File Uploads & Camera Access:** Modern photo, video, and file selection using native iOS pickers.
*   **Push Notifications:** Integrated Firebase Cloud Messaging. **(Requires a paid Apple Developer account)**.
*   **Configuration Driven:** All major features are controlled via `swv.properties`, mirroring the Android version for easy management.
*   **Location & Permissions:** Access device GPS/location and manage permissions with a centralized manager.
*   **Content Sharing & URL Handling:** Intercept custom URL schemes (`tel:`, `share:`, `print:`) and intelligently open external links in the browser.
*   **Downloads & Printing:** Handle file downloads and print web content using native iOS services.
*   **Modern WebView:** Built on `WKWebView` for maximum performance, security, and compatibility.
*   **SwiftUI Lifecycle:** Built using the modern SwiftUI app lifecycle for future-proofing and easier cross-platform (iPadOS, macOS) support.

---

## Important Note on Apple Developer Accounts

Some advanced iOS features require a paid Apple Developer account ($99/year). This project is structured to work for both free and paid accounts, but certain plugins will only be fully functional with a paid account.

| Feature / Plugin | Free Account | Paid Account |
| :--- | :--- | :--- |
| Core WebView, File Uploads, Location, Dialogs, Toast | ✅ Yes | ✅ Yes |
| **[Push Notifications](https://developer.apple.com/help/account/identifiers/enable-app-capabilities) (FirebasePlugin)** | ❌ No | ✅ **Yes** |
| Other capabilities (iCloud, HealthKit, etc.) | ❌ No | ✅ **Yes** |

**If you are using a free account, the app will build and run, but Push Notifications will be disabled.**

---

## Quick Start

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/mgks/iOS-SmartWebView.git
    ```
2.  **Open in Xcode:**
    *   Open the `.xcodeproj` file.
    *   In Xcode, go to **Settings > Accounts** and ensure you are logged in with your Apple ID.
3.  **Configure `swv.properties`:**
    *   Open `Resources/swv.properties`.
    *   Change `app.url` to your website's URL.
4.  **Add `GoogleService-Info.plist` (Optional):**
    *   If using Firebase services, obtain your `GoogleService-Info.plist` file from the Firebase console and place it in the `Resources/` group in Xcode.
5.  **Configure Project Capabilities (Based on Account Type):**
    *   In your Project Target settings, go to the **"Signing & Capabilities"** tab.
    *   **Free Account:** No action needed. The project is pre-configured to build without paid capabilities.
    *   **Paid Account:** Click **`+ Capability`** and add **`Push Notifications`**. This is required for the `FirebasePlugin` to receive remote notifications.
6.  **Add Privacy Permissions:**
    *   In the **Info** tab of your project target, add the following keys with descriptions of why you need them. The app will crash without these.
        *   `Privacy - Camera Usage Description`
        *   `Privacy - Photo Library Usage Description`
        *   `Privacy - Location When In Use Usage Description`
        *   `Privacy - Microphone Usage Description` (for video recording)
7.  **Build & Run:**
    *   Select a simulator or connected device and press the Run `▶` button.

## Understanding the Code

*   **`Resources/swv.properties`**: Contains all global configurations.
*   **`Managers/SWVContext.swift`**: The central class that loads the configuration and holds app state.
*   **`Core/ContentView.swift` & `Views/WebView.swift`**: The main entry point and WebView setup.
*   **`Managers/URLHandler.swift`**: Utility for handling custom URL schemes and external links.
*   **`Plugins/PluginInterface.swift` & `Managers/PluginManager.swift`**: Key components of the plugin architecture.
*   **`Plugins/` directory**: Contains example and premium plugin implementations.
*   **`Core/AppDelegate.swift`**: Handles application-level events, primarily for configuring Firebase and receiving push notifications.

## Contributing & Support
*   Found a bug or want to contribute? Open an issue or create a pull request.
*   Support the project via [GitHub Sponsors](https://github.com/sponsors/mgks).

## License
This project is licensed under the [MIT License](LICENSE).
