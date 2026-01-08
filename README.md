# 🌊 WaterGuard

**Sistem Pelaporan & Penanganan Masalah Perairan Berbasis Mobile**

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

WaterGuard adalah aplikasi mobile yang dirancang untuk memudahkan masyarakat dalam melaporkan masalah lingkungan perairan (seperti banjir, pencemaran, atau saluran tersumbat) secara *real-time*. Aplikasi ini juga memfasilitasi perekrutan sukarelawan lingkungan dan menyediakan transparansi status penanganan laporan.

---

## 📱 Fitur Utama

### 1. Pelaporan Masalah (User)
* **Geo-tagging:** Otomatis mengambil koordinat lokasi (Latitude/Longitude) pengguna saat melapor.
* **Bukti Visual:** Upload foto kejadian langsung dari galeri.
* **Tracking Status:** Memantau status laporan (Menunggu, Diproses, Selesai, Ditolak).

### 2. Manajemen Sukarelawan (Volunteer)
* **Pendaftaran Digital:** Formulir pendaftaran relawan terintegrasi.
* **Upload CV:** Validasi ketat untuk upload dokumen CV (PDF/Gambar) dengan batas ukuran **Max 500KB** untuk menjaga performa database.
* **Role-Based Access:** Pengguna yang diterima otomatis mendapatkan akses menu khusus Relawan.

### 3. Panel Admin (Admin)
* **Verifikasi Laporan:** Admin dapat mengubah status laporan warga.
* **Kelola Relawan:** Melihat daftar pendaftar, **membuka file CV** (decode Base64 ke file fisik), dan menerima/menolak lamaran.
* **Dashboard Interaktif:** Menu navigasi khusus berdasarkan role pengguna.

### 4. Fitur Lainnya
* **Multi-Bahasa:** Dukungan penuh Bahasa Indonesia (`id`) dan Inggris (`en`) menggunakan `easy_localization`.
* **Peta Lokasi:** Visualisasi titik masalah pada peta.
* **Keamanan Data:** Validasi input form yang ketat dan enkripsi password.

---

## 🛠️ Teknologi yang Digunakan

* **Framework:** [Flutter](https://flutter.dev/) (SDK 3.x)
* **Bahasa:** Dart
* **Backend & Database:**
    * **Firebase Authentication:** Manajemen user (Login/Register).
    * **Cloud Firestore:** Database NoSQL untuk menyimpan data laporan, user, dan file (Base64).
* **State Management:** `setState` (Native).
* **Testing:** `flutter_test` (Unit Testing).

### Library Kunci (Dependencies)
* `geolocator`: Akses GPS.
* `file_picker`: Pemilihan file dokumen/gambar.
* `open_filex`: Membuka file dokumen secara native di Android.
* `path_provider`: Akses penyimpanan sementara (cache).
* `shared_preferences`: Penyimpanan data lokal sederhana.
* `easy_localization`: Internasionalisasi bahasa.

---

## 🚀 Cara Instalasi & Menjalankan

Ikuti langkah berikut untuk menjalankan project ini di komputer lokal Anda:

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/username-anda/waterguard.git](https://github.com/username-anda/waterguard.git)
    cd waterguard
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Firebase**
    Pastikan Anda memiliki file `google-services.json` (Android) atau konfigurasi Firebase yang sesuai. Jika menggunakan FlutterFire CLI:
    ```bash
    flutterfire configure
    ```

4.  **Jalankan Aplikasi**
    Pastikan emulator Android sudah berjalan.
    ```bash
    flutter run
    ```

---

## 🧪 Unit Testing

Project ini dilengkapi dengan **Unit Testing** untuk memastikan logika bisnis berjalan dengan benar, mencakup validasi input dan logika file upload.

Untuk menjalankan pengujian:
```bash
flutter test test/waterguard_core_test.dart
