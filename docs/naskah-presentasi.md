# Naskah Presentasi
## Aplikasi Manajemen Magang & PKL - UMPAR

---

## 1. Pembuka (Salam)

"Assalamualaikum Warahmatullahi Wabarakatuh.

Selamat pagi/siang, Bapak/Ibu Dosen Penguji yang saya hormati.

Perkenalkan, nama saya [NAMA ANDA], NIM [NIM ANDA]. Pada kesempatan ini, saya akan mempresentasikan hasil pengembangan aplikasi Manajemen Magang dan PKL untuk Universitas Muhammadiyah Parepare."

---

## 2. Latar Belakang Masalah

"Saat ini, proses administrasi magang dan Praktik Kerja Lapangan (PKL) di banyak institusi masih dilakukan secara manual. Hal ini menyebabkan beberapa kendala:

1. **Proses Pengajuan Memakan Waktu** - Mahasiswa harus bolak-balik ke ruang administrasi.
2. **Kesulitan Monitoring** - Dosen pembimbing sulit memantau progress magang secara real-time.
3. **Dokumentasi Tidak Terpusat** - Dokumen seperti laporan harian dan kehadiran tersebar di berbagai tempat.
4. **Keterbatasan Akses Informasi** - Pihak instansi tidak memiliki panel untuk melihat data peserta magang mereka.

Berdasarkan permasalahan tersebut, saya mengembangkan aplikasi berbasis Flutter yang mengintegrasikan seluruh proses tersebut dalam satu platform digital."

---

## 3. Tujuan Pengembangan

"Aplikasi ini dikembangkan dengan tujuan:

1. Menyediakan sistem pengajuan magang dan PKL secara online.
2. Memfasilitasi monitoring kehadiran peserta dengan sistem check-in berbasis lokasi.
3. Mempermudah dosen/guru pembimbing dalam memberikan bimbingan dan penilaian.
4. Menyediakan dashboard terintegrasi untuk Admin Fakultas dan Admin Sekolah."

---

## 4. Arsitektur & Teknologi

"Aplikasi ini dibangun menggunakan arsitektur **Client-Server**:

| Komponen        | Teknologi               |
|-----------------|-------------------------|
| **Frontend**    | Flutter (Dart)          |
| **Backend**     | PHP Native (REST API)   |
| **Database**    | MySQL                   |
| **State Mgmt**  | Provider (Flutter)      |

Flutter dipilih karena kemampuannya untuk multi-platform (Android, iOS, Windows, Web) dengan satu codebase."

---

## 5. Fitur Utama Berdasarkan Role

### A. Mahasiswa/Siswa
- Pengajuan Magang/PKL online
- Input absensi harian dengan GPS
- Upload laporan harian & monitoring
- Melihat nilai dari pembimbing

### B. Dosen/Guru Pembimbing
- Verifikasi dan persetujuan pengajuan
- Jadwal sesi bimbingan
- Review laporan mahasiswa
- Input penilaian

### C. Instansi
- Konfirmasi penerimaan peserta magang
- Review kehadiran peserta
- Input penilaian dari sisi industri

### D. Admin Fakultas/Sekolah
- Verifikasi pengajuan (level fakultas/sekolah)
- Alokasi dosen/guru pembimbing
- Monitoring seluruh pengajuan
- Kelola data pembimbing

### E. Super Admin
- Kelola seluruh pengguna sistem
- Dashboard statistik global

---

## 6. Tantangan, Bug, dan Mismatch dalam Pengembangan (PENTING - DISAMPAIKAN TRANSPARAN)

"Sebelum Bapak/Ibu Dosen mengajukan pertanyaan, izinkan saya menyampaikan secara **transparan dan jujur** mengenai berbagai tantangan teknis, bug, dan ketidaksesuaian yang saya temui selama pengembangan aplikasi ini. Saya percaya kejujuran ini adalah bagian dari pembelajaran.

---

### 6.1. Kompleksitas Sistem Multi-Role (8 Role)

Aplikasi ini memiliki **8 role pengguna**:
1. Super Admin
2. Admin Fakultas  
3. Admin Sekolah
4. Mahasiswa
5. Siswa
6. Dosen Pembimbing
7. Guru Pembimbing
8. Instansi

**Implikasi teknis:**
- Setiap role memiliki **dashboard berbeda**, **menu berbeda**, dan **akses data berbeda**.
- Total: **18+ tabel database** yang saling berelasi.
- Total: **50+ endpoint API** dengan otorisasi berbeda.
- Total: **30+ halaman Flutter** dengan kondisi tampilan dinamis.

**Masalah yang timbul:**
Karena banyaknya role, terjadi **kebingungan navigasi** dimana halaman yang sama (misal: 'Pengajuan') memiliki tampilan dan fungsi berbeda tergantung role. Ini menyebabkan beberapa bug navigasi yang akan saya jelaskan.

---

### 6.2. Bug dan Error yang Ditemukan Selama Pengembangan

Berikut adalah daftar **bug aktual yang saya temui dan perbaiki** selama proses development:

#### 🔴 Bug #1: Database Table Name Mismatch
- **Masalah:** Query SQL di backend menggunakan `FROM users` padahal nama tabel sebenarnya adalah `user` (tanpa 's').
- **Dampak:** Error 500 saat Admin Fakultas/Sekolah membuka dashboard.
- **File terdampak:** `AdminFakultasController.php`, `AdminSekolahController.php`, `DashboardController.php`
- **Solusi:** Koreksi nama tabel di semua JOIN statement.

#### 🔴 Bug #2: Halaman Pengajuan Tertukar (Student View vs Admin View)
- **Masalah:** Saat Admin Fakultas mengklik menu 'Pengajuan', aplikasi membuka halaman yang sama dengan Mahasiswa (tampilan untuk membuat pengajuan baru).
- **Penyebab:** Route `RuteAplikasi.pengajuanList` tidak membedakan konteks Admin vs Student.
- **Dampak:** Admin melihat tombol "Buat Pengajuan" yang seharusnya tidak ada.
- **Solusi:** Menambahkan parameter `isAdmin: true` dan `isMagang: true/false` ke routing.

#### 🔴 Bug #3: Menu Kehadiran Crash untuk Admin
- **Masalah:** Admin Fakultas/Sekolah mengklik menu 'Kehadiran' → Aplikasi crash/blank screen.
- **Penyebab:** Halaman `KehadiranHalaman` membutuhkan `id_pengajuan` (ID mahasiswa), tetapi Admin tidak memiliki konteks ID tersebut.
- **Solusi:** Redirect ke `MonitoringListHalaman` terlebih dahulu untuk memilih mahasiswa, baru navigasi ke halaman kehadiran.

#### 🔴 Bug #4: Role-Based Access Control Tidak Konsisten
- **Masalah:** Beberapa endpoint API tidak memeriksa role dengan benar.
- **Contoh:** Endpoint `/bimbingan` hanya memeriksa `mahasiswa`, `siswa`, `dosen`, `guru` — Admin Fakultas tidak bisa akses.
- **Solusi:** Menambahkan case untuk `admin_fakultas` dan `admin_sekolah` di controller.

#### 🔴 Bug #5: Type Inference Error pada Menu Grid
- **Masalah:** Flutter error "Couldn't infer type parameter 'E'" saat render menu dashboard Admin.
- **Penyebab:** List `menuItems` tidak memiliki explicit type annotation.
- **Solusi:** Mengubah `final menuItems = [...]` menjadi `final List<Map<String, dynamic>> menuItems = [...]`.

#### 🔴 Bug #6: Undefined Route Constants
- **Masalah:** Error "Undefined name 'monitoringList'" saat compile.
- **Penyebab:** Konstanta `monitoring` di-rename menjadi `monitoringList` tetapi tidak didefinisikan.
- **Solusi:** Menambahkan `static const String monitoringList = '/monitoring';` di `rute.dart`.

---

### 6.3. Ketidaksesuaian dengan Activity Diagram (MISMATCH)

Saya mengakui bahwa implementasi tidak 100% sesuai dengan Activity Diagram yang dirancang. Berikut detailnya:

#### ⚠️ Mismatch #1: Alur Approval Pengajuan
- **Di UML:** Pengajuan → Admin Approve → Dosen Approve → Instansi Approve (sequential)
- **Di Implementasi:** Approval bisa paralel dan tidak strict sequential karena:
  - Instansi mungkin sudah konfirmasi sebelum Dosen assign.
  - Admin bisa langsung approve tanpa menunggu Dosen.
- **Alasan:** Fleksibilitas real-world requirement.

#### ⚠️ Mismatch #2: State Pengajuan Tambahan
- **Di UML:** Status hanya: Diajukan, Disetujui, Ditolak, Selesai.
- **Di Implementasi:** Ditambah: Menunggu Instansi, Dibatalkan.
- **Alasan:** Kebutuhan tracking yang lebih detail berdasarkan testing.

#### ⚠️ Mismatch #3: Fitur Bimbingan
- **Di UML:** Bimbingan hanya bisa diajukan setelah pengajuan disetujui.
- **Di Implementasi:** Halaman bimbingan bisa diakses kapan saja (guard tidak strict).
- **Alasan:** Keterbatasan waktu untuk implementasi precondition check.

#### ⚠️ Mismatch #4: Cetak Surat
- **Di UML:** Generate PDF di server.
- **Di Implementasi:** Generate PDF di client-side (Flutter) menggunakan package `pdf`.
- **Alasan:** Lebih cepat dan tidak perlu konfigurasi server tambahan.

---

### 6.4. Nama Fitur yang Sama, Fungsi Berbeda (Collision Problem)

Salah satu tantangan terbesar adalah **penamaan fitur yang sama untuk role berbeda**:

| Nama Menu | Untuk Mahasiswa | Untuk Admin | Untuk Dosen |
|-----------|-----------------|-------------|-------------|
| Pengajuan | Form submit pengajuan | List semua pengajuan | List untuk verifikasi |
| Kehadiran | Input check-in | Monitoring mahasiswa | Monitoring bimbingan |
| Laporan | Submit laporan harian | Review laporan | Review & approve |
| Bimbingan | Request bimbingan | - | Jadwalkan bimbingan |

Masalah ini menyebabkan:
- Navigasi awalnya **misdirect ke halaman yang salah**.
- Perlu **logika kondisional** di setiap halaman untuk cek role.
- **Maintenance menjadi kompleks** karena satu halaman handle multiple scenario.

---

### 6.5. Debugging Multi-Platform

Flutter mendukung multi-platform, tetapi ini menambah kompleksitas:

- **Android:** Permission lokasi harus di-handle secara berbeda (fine vs coarse location).
- **Windows:** Tidak ada GPS hardware → Testing kehadiran harus dengan mock data.
- **Web:** CORS policy memblokir API call ke localhost.

---

### 6.6. Integrasi GPS untuk Absensi

Fitur check-in berbasis lokasi membutuhkan:
- Implementasi **Haversine Formula** untuk menghitung jarak.
- Handling **permission denied** scenario.
- **Fallback flow** jika GPS tidak aktif.
- Konfigurasi **radius toleransi** (berapa meter dari instansi yang dianggap valid).

---

### 6.7. Hal yang Belum Sempurna (Honest Disclosure)

Secara jujur, berikut fitur yang **belum sepenuhnya sesuai harapan**:

1. ❌ Notifikasi push real-time (belum ada Firebase integration)
2. ❌ Validasi radius lokasi check-in (saat ini accept semua lokasi)
3. ❌ Chat antara mahasiswa dan dosen (tidak diimplementasikan)
4. ❌ Export laporan ke Excel (hanya PDF)
5. ❌ Beberapa alternative flow di Activity Diagram diskip karena waktu

---

### 6.8. Pembelajaran dari Tantangan Ini

Dari semua tantangan di atas, saya belajar bahwa:

1. **UML adalah panduan, bukan kontrak absolut** — Adaptasi di lapangan adalah hal yang wajar.
2. **Testing dengan berbagai role itu krusial** — Bug seringkali baru muncul di role tertentu.
3. **Naming convention sangat penting** — Nama yang ambigu menyebabkan bug navigasi.
4. **Multi-role system membutuhkan perencanaan access control yang matang**.
5. **Iterative development lebih realistis** daripada waterfall strict.

Ini adalah pengalaman belajar yang **sangat berharga** bagi saya sebagai developer."


---

## 7. Kesesuaian dengan UML

"Untuk menjawab pertanyaan mengenai kesesuaian implementasi dengan UML:

### Yang Sudah Sesuai:
✅ Use Case utama (Pengajuan, Verifikasi, Bimbingan, Penilaian, Laporan)
✅ Activity Diagram alur pengajuan multi-approval
✅ Class Diagram entitas utama (User, Pengajuan, Kehadiran, Bimbingan, Laporan, Nilai)
✅ Sequence Diagram untuk proses login dan submit pengajuan

### Yang Ada Penyesuaian:
⚠️ Beberapa alternative flow pada Activity Diagram disederhanakan karena keterbatasan waktu.
⚠️ State Diagram status pengajuan ditambah state 'Menunggu Instansi' yang tidak ada di rancangan awal.
⚠️ Beberapa method pada Class Diagram digabung untuk efisiensi.

### Alasan Penyesuaian:
1. **Keterbatasan waktu pengembangan** - Fokus pada core functionality.
2. **Feedback dari pengujian awal** - Beberapa flow dianggap terlalu rumit oleh tester.
3. **Perbaikan bug prioritas** - Waktu dialokasikan untuk fixing daripada fitur baru.

Ini adalah **pengalaman belajar yang berharga** karena dalam industri software development yang sesungguhnya, adaptasi seperti ini lazim terjadi."

---

## 8. Demonstrasi Aplikasi

"Sekarang, saya akan mendemonstrasikan aplikasi melalui skenario:

1. **Login sebagai Mahasiswa** → Submit pengajuan magang
2. **Login sebagai Admin Fakultas** → Verifikasi & assign dosen
3. **Login sebagai Dosen** → Approve dan jadwal bimbingan
4. **Login sebagai Mahasiswa** → Check-in kehadiran
5. **Login sebagai Instansi** → Konfirmasi penerimaan

[DEMO APLIKASI]"

---

## 9. Kesimpulan

"Dari pengembangan aplikasi ini, saya dapat menyimpulkan:

1. Aplikasi Manajemen Magang & PKL berhasil dikembangkan menggunakan Flutter dan PHP API.
2. Sistem multi-role berhasil diimplementasikan dengan kontrol akses yang tepat.
3. Proses pengembangan mengajarkan pentingnya **fleksibilitas dalam menghadapi kompleksitas**.
4. UML sangat membantu sebagai panduan, tetapi **implementasi nyata memerlukan adaptasi**."

---

## 10. Saran Pengembangan Lanjutan

"Untuk pengembangan ke depan, saya menyarankan:

1. Integrasi dengan SSO (Single Sign-On) kampus.
2. Notifikasi push real-time menggunakan Firebase.
3. Fitur chat antara mahasiswa dan pembimbing.
4. Dashboard analytics dengan grafik interaktif.
5. Ekspor laporan ke format PDF/Excel."

---

## 11. Penutup

"Demikian presentasi yang dapat saya sampaikan. Saya menyadari masih banyak kekurangan dalam aplikasi ini, dan saya sangat terbuka untuk masukan dari Bapak/Ibu Dosen.

Terima kasih atas perhatiannya.
Wassalamualaikum Warahmatullahi Wabarakatuh."

---

## Catatan untuk Presenter

> **Tips menghadapi pertanyaan sulit:**
> - Jika ditanya "Kenapa tidak sesuai UML?", jawab dengan jujur bahwa ini adalah pembelajaran tentang gap antara perencanaan dan implementasi.
> - Jika ditanya fitur yang belum jadi, tekankan bahwa Anda sudah mendokumentasikan sebagai saran pengembangan.
> - Gunakan istilah "iterative development" dan "agile approach" untuk menjelaskan adaptasi.

> **Mindset:**
> Anda sudah bekerja keras. Apapun hasilnya, ini adalah pengalaman belajar yang bernilai. Software development memang tidak pernah sempurna pada iterasi pertama.
