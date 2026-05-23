# SIKA PWA Web View

Aplikasi Flutter Enterprise-Grade yang bertindak sebagai *Secure Gatekeeper* (WebView wrapper) untuk sistem PWA (Progressive Web App) Sistem Informasi Karyawan Kasih Ibu (SIKA).

Aplikasi ini dibangun dengan mengimplementasikan prinsip **Clean Architecture** berlapis untuk menjamin keamanan perangkat, validasi konektivitas yang ketat, serta performa aplikasi yang tinggi.

## 🚀 Fitur Utama

- **Enterprise Clean Architecture**: Struktur kode dipisahkan ke dalam *Presentation*, *Domain*, dan *Data* layer untuk skalabilitas.
- **Strict Security Validation (Gatekeeper)**: Memvalidasi lingkungan perangkat sebelum WebView dapat diakses:
  - 🛡️ **Android SDK Validation**: Mendukung minimal API 24 (Nougat) dan memvalidasi ketersediaan WebView sistem.
  - 🌐 **VPN Detection**: Memblokir pengguna yang mengaktifkan koneksi VPN (Native Detection).
  - 📍 **Mock Location Protection**: Mencegah pemalsuan GPS dengan perlindungan ganda (Native + Plugin).
  - 👨‍💻 **Developer Mode Check**: Memblokir akses jika opsi pengembang (*Developer Options*) diaktifkan.
- **2-Stage Connectivity Check**: Memastikan perangkat terhubung dengan *network* (WiFi/Data) dan memiliki akses aktual ke *internet* (mengatasi *captive portal*).
- **PWA WebView Container**: Integrasi `flutter_inappwebview` dengan fitur *file download* via `MediaStore` Android, akses *camera/storage*, dan integrasi geolokasi secara dinamis ke dalam JavaScript web.

---

## 🛠️ Persiapan & Instalasi

### 1. Environment Configuration
Aplikasi ini membutuhkan file `.env` di *root directory*. Buat file `.env` dan masukkan konfigurasi berikut:

```env
PROD_URL=https://your-pwa-url.com
```

### 2. Instalasi Dependensi
Jalankan perintah berikut untuk mengunduh semua dependensi:
```bash
flutter pub get
```

### 3. Menjalankan Aplikasi
Aplikasi ini dirancang khusus untuk Android. Jalankan menggunakan:
```bash
flutter run
```

---

## 🏗️ Struktur Arsitektur (Clean Architecture)

Aplikasi SIKA disusun ke dalam struktur folder *Feature-Based* dengan setiap fiturnya mengadopsi pola:
`Presentation → Domain ← Data`

```text
lib/
├── core/                  # Aturan fondasi (Constants, Failures, Themes)
├── features/              # Fitur modular aplikasi
│   ├── app/               # Entry point (App, Routes, Bindings DI)
│   ├── sdk_validation/    # Validasi Android OS SDK
│   ├── connectivity/      # Cek ketersediaan Internet
│   ├── security/          # Cek VPN, Mock Location, Developer Mode
│   ├── splash/            # Splash Screen yang mengatur alur startup
│   └── webview/           # Kontainer PWA InAppWebView
└── shared/                # Widget & Helper yang dapat digunakan kembali
```

---

## 🔒 Alur Keamanan Saat Startup (Lifecycle Rules)

Aplikasi secara ketat mengikuti urutan validasi berikut saat dijalankan:

1. **App Launch** (menampilkan Splash Screen)
2. **SDK Validation**: Mengecek versi Android dan ketersediaan WebView bawaan Android.
3. **Internet Validation**: Cek koneksi lokal dan akses ping aktual ke internet.
4. **Security Validation**: Mengecek status VPN, Fake GPS, dan Developer Mode.
5. **Runtime Permissions**: Meminta akses Lokasi, Kamera, dan Penyimpanan.
6. **Load WebView**: Kontainer PWA akhirnya di-load dengan menyuntikkan koordinat geolokasi asli dari perangkat.

Jika *salah satu* dari urutan ke-2 hingga ke-4 gagal, pengguna akan diarahkan ke layar *blocking* atau *error* (seperti `UnsupportedDeviceScreen`, `NoInternetScreen`, atau `BlockingScreen`) dan tidak bisa melanjutkan ke dalam PWA.

---

## 📍 Penanganan Geolokasi (Geolocation Handling)

Aplikasi secara diam-diam memonitor pergerakan lokasi secara *real-time* dan terus menyuntikkannya ke dalam konteks JavaScript WebView.
- Helper `LocationHelper` akan secara konstan memonitor `location.onLocationChanged`.
- Saat lokasi berubah, fungsi `window.__flutterUpdateGeolocation(lat, lng)` dipanggil dalam DOM WebView.
- Pengecekan Mock Location juga selalu berjalan selama *streaming* berlangsung. Jika Fake GPS tiba-tiba diaktifkan, aplikasi akan langsung menendang pengguna ke layar pemblokiran.

---

## 🐞 Troubleshooting

- **Aplikasi Terhenti di Splash Screen**: Pastikan perangkat terhubung ke internet dan URL di `.env` sudah benar.
- **Dilempar ke Layar "Keamanan Tidak Terjamin"**: Pastikan Anda telah mematikan VPN, mematikan aplikasi Mock Location, dan **mematikan Developer Mode** di pengaturan HP Android.
- **File Gagal Didownload (Error Permission)**: Pastikan aplikasi sudah diberikan izin untuk Storage. File akan diunduh menggunakan native Android MethodChannel ke folder `Downloads` perangkat.
- **Compile Error (Unresolved Reference)**: Pastikan Anda menggunakan versi Gradle dan Android compile SDK terbaru (targetSdk 34+).
