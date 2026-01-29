# 🎓 MagangKu - Sistem Manajemen Magang & PKL

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
</p>

<p align="center">
  <strong>Aplikasi manajemen Magang dan Praktik Kerja Lapangan (PKL) terintegrasi untuk Universitas Muhammadiyah Parepare</strong>
</p>

---

## 📋 Deskripsi

**MagangKu** adalah aplikasi mobile cross-platform yang mengintegrasikan seluruh proses administrasi kegiatan Magang (Mahasiswa) dan Praktik Kerja Lapangan/PKL (Siswa) dalam satu ekosistem digital. Aplikasi ini mendukung **8 role pengguna** dengan alur kerja yang berbeda namun saling terhubung.

### 🎯 Masalah yang Diselesaikan

- ❌ Proses pengajuan manual berbasis kertas yang lambat
- ❌ Kesulitan monitoring kehadiran peserta di lapangan
- ❌ Komunikasi tidak terstruktur antara peserta dan pembimbing
- ❌ Disparitas data antara fakultas, sekolah, dan instansi mitra

### ✅ Solusi yang Ditawarkan

- ✅ Digitalisasi pengajuan dengan workflow approval bertingkat
- ✅ Monitoring kehadiran berbasis GPS (Geo-fencing)
- ✅ Bimbingan online terintegrasi dengan notifikasi
- ✅ Dashboard terpusat untuk setiap pemangku kepentingan

---

## 🌟 Fitur Utama

### 👥 Multi-Role System (8 Aktor)

| Role | Fungsi Utama |
|------|-------------|
| **Mahasiswa** | Pengajuan Magang, Check-in GPS, Laporan Harian, Request Bimbingan |
| **Siswa** | Pengajuan PKL, Check-in GPS, Laporan Harian, Request Bimbingan |
| **Dosen Pembimbing** | Verifikasi, Monitoring, Review Laporan, Penilaian |
| **Guru Pembimbing** | Verifikasi, Monitoring, Review Laporan, Penilaian |
| **Admin Fakultas** | Kelola data Magang, Assign Dosen, Verifikasi tingkat Fakultas |
| **Admin Sekolah** | Kelola data PKL, Assign Guru, Verifikasi tingkat Sekolah |
| **Instansi** | Konfirmasi penerimaan, Monitoring kehadiran, Penilaian industri |
| **Super Admin** | Kelola seluruh pengguna dan konfigurasi sistem |

### 📍 Fitur Kehadiran (GPS-Based Attendance)

- Check-in dan Check-out dengan validasi lokasi
- Radius toleransi yang dapat dikonfigurasi
- Riwayat kehadiran lengkap dengan statistik
- Input manual untuk izin/sakit dengan keterangan

### 📝 Fitur Pelaporan

- Laporan Harian dengan upload foto kegiatan
- Laporan Monitoring berkala
- Review dan feedback dari pembimbing
- Export ke format PDF

### 🎓 Fitur Bimbingan Online

- Request jadwal bimbingan
- Penjadwalan oleh pembimbing
- Catatan hasil bimbingan
- Rating dan feedback setelah sesi

### 📊 Dashboard & Statistik

- Dashboard real-time untuk setiap role
- Grafik statistik pengajuan dan kehadiran
- Notifikasi aktivitas terbaru

---

## 🛠️ Tech Stack

### Frontend (Mobile)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences

### Backend (API)
- **Language**: PHP 8.x (Native REST API)
- **Authentication**: JWT Token
- **Pattern**: Controller-based architecture

### Database
- **RDBMS**: MySQL 8.x
- **Tables**: 18+ tabel terintegrasi

---

## 📁 Struktur Proyek

```
umpar_magang_dan_pkl/
├── 📂 api/                          # Backend REST API
│   ├── config/                      # Konfigurasi database
│   ├── controllers/                 # Controller untuk setiap modul
│   │   ├── AuthController.php
│   │   ├── PengajuanController.php
│   │   ├── KehadiranController.php
│   │   ├── BimbinganController.php
│   │   ├── LaporanController.php
│   │   └── ...
│   ├── helpers/                     # Helper functions
│   │   └── Response.php             # Smart Response Handler
│   └── index.php                    # Router/Entry point
│
├── 📂 lib/                          # Flutter Source Code
│   ├── data/
│   │   ├── api/                     # API Client
│   │   └── model/                   # Data Models
│   ├── provider/                    # State Management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── pengajuan_provider.dart
│   │   ├── kehadiran_provider.dart
│   │   └── ...
│   ├── tampilan/
│   │   ├── halaman/                 # Pages/Screens
│   │   │   ├── auth/
│   │   │   ├── mahasiswa/
│   │   │   ├── siswa/
│   │   │   ├── dosen/
│   │   │   ├── guru/
│   │   │   ├── admin_fakultas/
│   │   │   ├── admin_sekolah/
│   │   │   ├── instansi/
│   │   │   └── admin/
│   │   └── komponen/                # Reusable Widgets
│   ├── konfigurasi/
│   │   ├── konstanta.dart           # App Constants
│   │   └── rute.dart                # Route Configuration
│   └── main.dart                    # Entry Point
│
├── 📂 database/                     # SQL Files
│   └── magang_umpar.sql
│
├── 📂 docs/                         # Documentation
│   ├── naskah-presentasi.md
│   └── panduan-aplikasi.md
│
└── pubspec.yaml                     # Flutter Dependencies
```

---

## 🚀 Instalasi

### Prasyarat

- Flutter SDK 3.x ([Install Flutter](https://flutter.dev/docs/get-started/install))
- PHP 8.x
- MySQL 8.x
- XAMPP/Laragon/WAMP (untuk local development)
- Android Studio / VS Code

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/umpar_magang_dan_pkl.git
cd umpar_magang_dan_pkl
```

### Step 2: Setup Database

1. Buka phpMyAdmin atau MySQL client
2. Buat database baru: `magang_umpar`
3. Import file `database/magang_umpar.sql`

### Step 3: Konfigurasi Backend

1. Salin folder `api/` ke direktori web server:
   - **XAMPP**: `C:/xampp/htdocs/api/`
   - **Laragon**: `C:/laragon/www/api/`

2. Edit konfigurasi database di `api/config/database.php`:
```php
$host = 'localhost';
$dbname = 'magang_umpar';
$username = 'root';
$password = '';
```

### Step 4: Konfigurasi Flutter

1. Update base URL API di `lib/data/api/api_client.dart`:
```dart
static const String baseUrl = 'http://localhost/api'; // Sesuaikan
```

2. Install dependencies:
```bash
flutter pub get
```

### Step 5: Jalankan Aplikasi

```bash
# Jalankan di Android Emulator
flutter run

# Jalankan di Windows
flutter run -d windows

# Jalankan di Chrome (Web)
flutter run -d chrome
```

---

## 📱 Screenshots

> *Tambahkan screenshot aplikasi di sini*

| Login | Dashboard Mahasiswa | Kehadiran |
|-------|-------------------|-----------|
| ![Login](docs/screenshots/login.png) | ![Dashboard](docs/screenshots/dashboard.png) | ![Kehadiran](docs/screenshots/kehadiran.png) |

---

## 📖 Dokumentasi

- [Panduan Penggunaan Aplikasi](docs/panduan-aplikasi.md)
- [Naskah Presentasi](docs/naskah-presentasi.md)

---

## 🔧 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login pengguna |
| POST | `/auth/register` | Registrasi pengguna baru |
| GET | `/auth/profile` | Get profil pengguna |

### Pengajuan
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pengajuan` | List pengajuan |
| POST | `/pengajuan` | Buat pengajuan baru |
| PUT | `/pengajuan/{id}/approve` | Approve pengajuan |
| PUT | `/pengajuan/{id}/reject` | Reject pengajuan |

### Kehadiran
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/kehadiran` | Riwayat kehadiran |
| POST | `/kehadiran/checkin` | Check-in |
| POST | `/kehadiran/checkout` | Check-out |

### Bimbingan
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/bimbingan` | List bimbingan |
| POST | `/bimbingan` | Request bimbingan |
| PUT | `/bimbingan/{id}/schedule` | Jadwalkan bimbingan |

---

## 👥 Tim Pengembang

| Nama | Role | Kontak |
|------|------|--------|
| Hamrah, S.Kom., M.Kom. | Pembimbing | - |
| Nuraini | Developer | - |
| Muh. Taufiqurrahman | Developer | - |
| Sity Nur Khadijah S. | Developer | - |
| Abd. Jabbar | Developer | - |

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan akademis di **Universitas Muhammadiyah Parepare**.

---

## 🙏 Ucapan Terima Kasih

- Universitas Muhammadiyah Parepare
- Fakultas Teknik - Program Studi Informatika
- Seluruh instansi mitra yang berpartisipasi dalam pengujian

---

<p align="center">
  <strong>Made with ❤️ by UMPAR Informatics Team</strong>
</p>
