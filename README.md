# iOS Smart WebView

<p>
  <a href="#features"><img alt="Variant" src="https://img.shields.io/badge/language-Swift-orange.svg"></a>
  <a href="https://github.com/mgks/Android-SmartWebView/releases"><img alt="Based on" src="https://img.shields.io/github/v/release/mgks/android-smartwebview"></a>
  <a href="https://github.com/mgks/Android-SmartWebView/blob/master/LICENSE"><img alt="GitHub License" src="https://img.shields.io/github/license/mgks/android-smartwebview"></a>
</p>

**iOS Smart WebView** is a modern, open-source solution for building advanced hybrid iOS apps, designed as a direct parallel to the popular [Android Smart WebView](https://github.com/mgks/Android-SmartWebView) project. It allows you to effortlessly extend your app with plugins, native features, and a customizable UI, all configured from a single properties file.

**[DOCUMENTATION](https://docs.mgks.dev/smart-webview/)** | **[GET PREMIUM PLUGINS](https://github.com/sponsors/mgks/sponsorships?sponsor=mgks&tier_id=468838)** | **[ISSUES](https://github.com/mgks/Android-SmartWebView/issues)**

## Core Features

*   **Plugin Architecture:** Extend app functionality with self-registering plugins written in Swift. See `PluginInterface.swift`, `PluginManager.swift`, and existing plugins in `/Plugins/` for details.
*   **File Uploads & Camera Access:** Modern photo and video selection using the native iOS `PHPicker`.
*   **Push Notifications:** Integrated Firebase Cloud Messaging (requires `GoogleService-Info.plist`).
*   **Configuration Driven:** All major features are controlled via `swv.properties`, mirroring the Android version for easy management.
*   **Location & Permissions:** Access device GPS/location and manage permissions with a centralized manager.
*   **Content Sharing & URL Handling:** Intercept custom URL schemes (`tel:`, `share:`, `print:`) and intelligently open external links in the browser.
*   **Downloads & Printing:** Handle file downloads and print web content using native iOS services.
*   **Modern WebView:** Built on `WKWebView` for maximum performance, security, and compatibility.
*   **SwiftUI Lifecycle:** Built using the modern SwiftUI app lifecycle for future-proofing and easier cross-platform (iPadOS, macOS) support.

## Quick Start

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/YOUR_REPO/iOS-SmartWebView.git
    ```
2.  **Open in Xcode:**
    *   Open the `.xcodeproj` file.
3.  **Configure `swv.properties`:**
    *   Open `Resources/swv.properties`.
    *   Change `app.url` to your website's URL and adjust other settings as needed.
4.  **Add `GoogleService-Info.plist` (Optional):**
    *   If using Firebase services (like Push Notifications), obtain your `GoogleService-Info.plist` file from the Firebase console and place it in the `Resources/` group in Xcode.
5.  **Build & Run:**
    *   Select a simulator or connected device and press the Run (▶) button.

## Basic Configuration

All primary configuration is done within `Resources/swv.properties`:

*   **Main Application URL:**
    *   Set `app.url` to your web application's address.
    *   `offline.url` (`offline.html`) is used if no internet is detected.
*   **Feature Toggles:**
    *   Enable or disable features (file uploads, pull-to-refresh, etc.) by modifying the `feature.*` boolean properties.
*   **Permissions:**
    *   Add your privacy usage descriptions in Xcode under **Project Settings > Info > Custom iOS Target Properties**. For example, add `Privacy - Location When In Use Usage Description` for GPS.
*   **Plugin Configuration:**
    *   Plugin behavior (like AdMob IDs or Biometric Auth on launch) will be configured in `Playground.swift`, similar to the Android version.

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
