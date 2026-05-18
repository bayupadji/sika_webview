# Sika PWA Web View

A Flutter application that displays a Progressive Web App (PWA) in a WebView.

## Features
- Displays PWA content in a WebView
- Requests necessary permissions (Location, Camera, Storage)
- Checks for and blocks mock/fake locations
- Injects real-time geolocation into WebView
- Handles network connectivity and loading states

## Setup

1. **Environment Configuration**
   Create a `.env` file in the root directory with the following content:

   ```env
   CURRENT_URL=https://your-pwa-url.com
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

## Usage

Run the application:

```bash
flutter run
```

## Key Features

### Geolocation Handling

The app overrides the browser's `navigator.geolocation` API to provide real-time location data from the native device.

- **Mock Location Detection**: Uses `detect_fake_location` to prevent usage of fake GPS
- **Real-time Updates**: Streams location updates and sends them to the WebView
- **WebView Integration**: Injects JavaScript to make the WebView believe it has native geolocation

### Permissions

Automatically requests the following permissions on startup:

- `Permission.location` - For location tracking
- `Permission.camera` - For camera access in PWA
- `Permission.storage` - For file storage operations

### Loading & Error Handling

- **Splash Screen**: Shows until the first page loads
- **Network Errors**: Displays an error page if the device is offline
- **PWA Errors**: Displays an error page if the URL is invalid or not found
- **Mock Location Errors**: Displays an error page if mock location is detected

## File Structure

- `main.dart`: Application entry point and routing
- `providers/splash_provider.dart`: Splash screen logic and network checks
- `providers/location_provider.dart`: Geolocation handling and mock detection
- `views/pwa_webview.dart`: Main WebView implementation
- `views/splash_page.dart`: Splash screen UI
- `views/error_page.dart`: Error state UI

## Troubleshooting

- **WebView not loading**: Ensure `CURRENT_URL` is correctly set in `.env`
- **Location not working**: Check if mock location is disabled and permissions are granted
- **Console errors**: Look for `[WebView Console]` messages in the terminal for debugging
