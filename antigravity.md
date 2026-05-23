# Anti-Gravity Rules — SIKA WebView App

## Project Overview

SIKA adalah aplikasi absensi berbasis Android menggunakan Flutter.

Aplikasi Android hanya berfungsi sebagai secure WebView wrapper untuk menjalankan web application absensi.

Sebelum user dapat mengakses WebView, aplikasi wajib melakukan validasi keamanan device dan validasi koneksi internet.

---

# Android SDK Validation Rule (MANDATORY)

Aplikasi WAJIB melakukan validasi Android SDK/version compatibility sebelum aplikasi dijalankan sepenuhnya.

Tujuan:
- memastikan kompatibilitas aplikasi
- menjaga stabilitas WebView
- memastikan security API Android berjalan optimal
- memastikan device menggunakan Android version yang masih didukung

---

# SDK Requirements

## Minimum SDK

```text
minSdkVersion: 24
```

Android di bawah SDK 24 TIDAK didukung.

---

## Target SDK

Aplikasi WAJIB selalu menggunakan:

```text
targetSdkVersion: latest stable Android SDK
```

WAJIB mengikuti update Android SDK terbaru yang stabil.

---

# SDK Validation Rules

## Mandatory Validation

Saat aplikasi startup, WAJIB melakukan pengecekan:

- current Android SDK version
- compatibility dengan minimum SDK
- compatibility dengan required security API
- WebView compatibility

---

# Unsupported SDK Handling

Jika Android version tidak didukung:

WAJIB:
- block akses aplikasi
- jangan load webview
- tampilkan unsupported device page

---

# Expected Message

```text
Versi Android Anda tidak didukung.
Silakan update perangkat untuk menggunakan aplikasi SIKA.
```

---

# SDK Flow

## Allowed SDK Flow

```text
App Launch
   ↓
SDK Validation
   ↓
SDK Supported
   ↓
Internet Validation
   ↓
Security Validation
   ↓
Load WebView
```

---

## Unsupported SDK Flow

```text
App Launch
   ↓
SDK Validation
   ↓
Unsupported SDK Detected
   ↓
Show Unsupported Device Screen
   ↓
Prevent WebView Access
```

---

# SDK Compatibility Rules

## MUST

WAJIB:
- gunakan latest stable compileSdkVersion
- gunakan latest stable targetSdkVersion
- maintain compatibility dengan Android security policy terbaru
- update dependency mengikuti Android SDK terbaru

---

## MUST NOT

TIDAK BOLEH:
- menggunakan deprecated Android API tanpa fallback
- menggunakan obsolete SDK target
- ignore Android SDK compatibility issue

---

# Recommended Android Configuration

## Gradle Configuration

```gradle
android {
    compileSdkVersion latestStable

    defaultConfig {
        minSdkVersion 24
        targetSdkVersion latestStable
    }
}
```

---

# WebView Compatibility

Aplikasi WAJIB memastikan:
- Android System WebView compatible
- Chrome WebView compatible
- WebView version tidak obsolete

Jika WebView tidak compatible:
- tampilkan warning/error page
- jangan load webview content

---

# Lifecycle Rules

## On App Start

Urutan validation WAJIB:

```text
1. SDK Validation
2. Internet Validation
3. Security Validation
4. WebView Initialization
```

---

# Future Compatibility Principle

Aplikasi harus siap mengikuti:
- Android SDK terbaru
- Android security policy terbaru
- Google Play policy terbaru
- WebView security update terbaru

# Tech Stack

## Main Stack

- Flutter
- Provider (State Management)
- webview_flutter
- Android Native Security Check
- Method Channel
- Android SDK

---

# Architecture Principle

Aplikasi WAJIB menggunakan:

- Clean Architecture
- Feature-based Structure
- Separation of Concerns
- Repository Pattern
- Provider Pattern

Tujuan utama arsitektur:

- scalable
- maintainable
- modular
- secure
- testable

---

# Project Structure

## Standard Folder Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── services/
│   ├── themes/
│   └── utils/
│
├── features/
│
│   ├── splash/
│   │   ├── presentation/
│   │   │   └── splashscreen.dart
│   │   │
│   │   └── providers/
│   │       └── splash_provider.dart
│   │
│   ├── security/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── webview/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── connectivity/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── app/
│       ├── app.dart
│       ├── routes.dart
│       └── bindings.dart
│
├── shared/
│   ├── extensions/
│   ├── helpers/
│   └── widgets/
│
└── main.dart
```

---

# Mapping Old Structure

## Existing Structure → New Structure

| Existing | New |
|---|---|
| `constants/` | `core/constants/` |
| `providers/` | `features/.../presentation/providers/` |
| `utils/` | `core/utils/` |
| `views/error_page.dart` | `features/security/presentation/screens/error_page.dart` |
| `views/pwa_webview.dart` | `features/webview/presentation/screens/pwa_webview.dart` |
| `views/splashscreen.dart` | `features/splash/presentation/splashscreen.dart` |

---

# Clean Architecture Layers

## 1. Presentation Layer

Digunakan untuk:
- UI rendering
- state management
- interaction handling
- webview lifecycle
- consume provider state

### Rules

Presentation layer:
- TIDAK boleh akses datasource langsung
- TIDAK boleh contain heavy business logic
- hanya memanggil usecase

---

## 2. Domain Layer

Layer inti business logic aplikasi.

### Responsibilities

- business rules
- entities
- usecases
- repository contract

### Rules

Domain layer:
- pure dart
- independen
- tidak bergantung Flutter
- tidak bergantung external package

---

## 3. Data Layer

Layer implementasi repository dan native integration.

### Responsibilities

- repository implementation
- native API communication
- method channel
- datasource handling
- security integration

### Rules

Data layer:
- implement repository contract
- handle android native logic
- handle datasource communication

---

# Internet Connectivity Validation (MANDATORY)

Aplikasi WAJIB melakukan validasi koneksi internet sebelum user dapat mengakses WebView.

Validasi internet merupakan bagian dari initialization flow.

---

# Internet Validation Rules

## Connection Requirements

Aplikasi harus memastikan:

- device memiliki koneksi internet
- internet benar-benar aktif
- endpoint/web app SIKA reachable
- bukan hanya sekadar terhubung ke WiFi/network

---

# Mandatory Internet Checks

## 1. Network Availability Check

Deteksi:
- WiFi connection
- mobile data connection
- active network state

---

## 2. Internet Reachability Check

WAJIB memastikan:
- internet benar-benar dapat diakses
- endpoint SIKA reachable
- bukan captive portal/fake network

Contoh:
- lightweight ping/check
- HEAD request
- connectivity validation

---

# If No Internet

Jika internet tidak tersedia:

WAJIB:
- jangan load webview
- tampilkan no internet page
- stop initialization process
- sediakan tombol retry

---

# No Internet Message

```text
Tidak ada koneksi internet.
Periksa jaringan Anda dan coba lagi.
```

---

# Security Rules (MANDATORY)

## 1. Mock Location Detection

Aplikasi WAJIB mendeteksi fake GPS / mock location.

### Validation Target

Deteksi:
- fake GPS apps
- mock provider
- injected location
- developer mock setting

### If Detected

WAJIB:
- block akses aplikasi
- jangan load webview
- tampilkan blocking page
- terminate session

### Expected Message

```text
Mock Location Detected
Akses aplikasi diblokir demi keamanan absensi.
```

---

## 2. Developer Mode Detection

Aplikasi WAJIB mendeteksi Developer Options aktif.

### Validation

Cek:
- DEVELOPMENT_SETTINGS_ENABLED
- USB Debugging
- ADB status

### If Detected

WAJIB:
- block aplikasi
- jangan load webview
- tampilkan error page

### Expected Message

```text
Developer Mode aktif.
Nonaktifkan Developer Options untuk melanjutkan.
```

---

## 3. VPN Detection

Aplikasi WAJIB mendeteksi VPN aktif.

### Validation Target

Deteksi:
- VPN transport
- tun interface
- VPN apps

### If Detected

WAJIB:
- block akses aplikasi
- stop semua request webview

### Expected Message

```text
VPN terdeteksi.
Matikan VPN untuk menggunakan aplikasi.
```

---

# Validation Flow

## Allowed Flow

```text
App Launch
   ↓
Internet Validation
   ↓
Internet Available
   ↓
Security Validation
   ↓
- Mock Location OFF
- Developer Mode OFF
- VPN OFF
   ↓
Load WebView
   ↓
Access Granted
```

---

## Blocked Flow

```text
App Launch
   ↓
Validation Process
   ↓
Violation Detected
   ↓
Show Blocking Screen
   ↓
Prevent WebView Access
```

---

## No Internet Flow

```text
App Launch
   ↓
Internet Validation
   ↓
No Internet Detected
   ↓
Show No Internet Screen
   ↓
Prevent WebView Access
```

---

# Security Feature Structure

## Security Domain Example

```text
features/security/
│
├── domain/
│   ├── entities/
│   │   └── security_status.dart
│   │
│   ├── repositories/
│   │   └── security_repository.dart
│   │
│   └── usecases/
│       ├── check_vpn.dart
│       ├── check_mock_location.dart
│       └── check_developer_mode.dart
```

---

# Connectivity Feature Structure

```text
features/connectivity/
│
├── domain/
│   ├── repositories/
│   │   └── connectivity_repository.dart
│   │
│   └── usecases/
│       └── check_internet_connection.dart
```

---

# Provider Rules

## Provider Responsibility

Provider hanya digunakan untuk:
- manage state
- expose UI state
- notify listeners

---

## Forbidden

Provider TIDAK BOLEH:
- access native API langsung
- contain validation logic
- contain business logic

---

## Recommended Providers

```text
SecurityProvider
WebViewProvider
SessionProvider
SplashProvider
ConnectivityProvider
```

---

# Dependency Rule

## Dependency Direction

```text
Presentation → Domain ← Data
```

### Rules

- Domain tidak boleh import Flutter
- Data depend ke Domain
- Presentation depend ke Domain
- Domain adalah layer paling independen

---

# Repository Pattern

## Mandatory Flow

```text
UI
 ↓
Provider
 ↓
UseCase
 ↓
Repository Contract
 ↓
Repository Implementation
 ↓
Datasource / Native API
```

---

# Method Channel Rules

## Placement

MethodChannel hanya boleh berada di:

```text
features/security/data/datasources/
```

---

## Forbidden

MethodChannel TIDAK BOLEH:
- dipanggil langsung dari UI
- dipanggil langsung dari provider

---

# WebView Rules

## Allowed

- HTTPS only
- Official SIKA domain only
- JavaScript enabled jika diperlukan
- session persistence

---

## Forbidden

- file access
- unknown external domain
- multiple window
- debug mode production

---

# Android Requirements

## Minimum SDK

```text
minSdkVersion: 24
```

---

## Required Permissions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

# Lifecycle Rules

## On App Start

WAJIB:
1. validasi internet
2. validasi security checks
3. tunggu semua hasil validasi
4. load webview hanya jika semua aman

---

## On Resume

WAJIB melakukan re-check:
- internet connectivity
- mock location
- VPN
- developer mode

Jika violation ditemukan:
- force block user
- close webview access

---

# Blocking Screen Rules

Blocking page wajib:
- fullscreen
- tidak bisa dismiss
- tampilkan alasan block
- memiliki tombol retry

---

# No Internet Screen Rules

No internet page wajib:
- fullscreen
- memiliki tombol retry
- tampilkan status koneksi
- tidak dapat bypass ke webview

---

# Performance Rules

## Target

- startup validation < 3 detik
- minimal memory overhead
- tidak mengganggu performa webview

---

# Testing Rules

## Mandatory Testing

### Domain Layer

WAJIB unit test:
- usecases
- repository contract
- business logic

---

### Data Layer

WAJIB test:
- repository implementation
- datasource logic

---

### Presentation Layer

WAJIB test:
- provider state
- UI rendering

---

# Production Rules

## Release Build

WAJIB:
- disable debug mode
- disable webview debugging
- enable obfuscation
- enable shrink resources

---

# Recommended Packages

## WebView

```yaml
webview_flutter
```

---

## State Management

```yaml
provider
```

---

## VPN Detection

```yaml
vpn_detector
```

---

## Developer Mode Detection

```yaml
flutter_jailbreak_detection
```

---

## Connectivity

```yaml
connectivity_plus
internet_connection_checker
```

---

## Mock Location Detection

Gunakan:
- Android Native API
- MethodChannel
- custom validation logic

---

# Future Security Scalability

Arsitektur harus siap untuk fitur berikut:

- root detection
- SSL pinning
- anti tamper
- screenshot prevention
- emulator detection
- biometric validation
- device binding

Semua fitur baru WAJIB mengikuti:
- clean architecture
- feature-based structure
- repository pattern

---

# Security Principle

Prioritas utama aplikasi:

1. Security
2. Integrity
3. Stability
4. UX

---

# Final Principle

SIKA bukan sekadar WebView wrapper.

Aplikasi Android bertindak sebagai secure gatekeeper sebelum user dapat mengakses sistem absensi.

Jika environment Android tidak aman:
- akses WAJIB ditolak
- webview TIDAK boleh dijalankan
- validasi keamanan selalu menjadi prioritas utama

Aplikasi harus:
- secure by default
- scalable
- modular
- maintainable
- enterprise-grade
- mudah di-test