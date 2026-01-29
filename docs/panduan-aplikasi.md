# Panduan Penggunaan Aplikasi
## Sistem Manajemen Magang & PKL - UMPAR

---

## Daftar Isi
1. [Instalasi & Menjalankan Aplikasi](#1-instalasi--menjalankan-aplikasi)
2. [Panduan untuk Mahasiswa](#2-panduan-untuk-mahasiswa)
3. [Panduan untuk Siswa (PKL)](#3-panduan-untuk-siswa-pkl)
4. [Panduan untuk Dosen Pembimbing](#4-panduan-untuk-dosen-pembimbing)
5. [Panduan untuk Guru Pembimbing](#5-panduan-untuk-guru-pembimbing)
6. [Panduan untuk Instansi](#6-panduan-untuk-instansi)
7. [Panduan untuk Admin Fakultas](#7-panduan-untuk-admin-fakultas)
8. [Panduan untuk Admin Sekolah](#8-panduan-untuk-admin-sekolah)
9. [Panduan untuk Super Admin](#9-panduan-untuk-super-admin)

---

## 1. Instalasi & Menjalankan Aplikasi

### Prasyarat
- PHP 7.4+ dengan XAMPP/Laragon
- MySQL Database
- Flutter SDK 3.0+

### Langkah Menjalankan Backend
1. Salin folder `api/` ke direktori `htdocs` (XAMPP) atau `www` (Laragon).
2. Import database dari file `magang_umpar.sql`.
3. Konfigurasi koneksi database di `api/config/database.php`.
4. Jalankan server Apache dan MySQL.

### Langkah Menjalankan Flutter App
```bash
# Install dependencies
flutter pub get

# Jalankan di Windows
flutter run -d windows

# Jalankan di Android/Emulator
flutter run
```

---

## 2. Panduan untuk Mahasiswa

### 2.1 Registrasi Akun
1. Buka aplikasi → Klik **"Daftar"**
2. Pilih role **"Mahasiswa"**
3. Isi data:
   - Nama Lengkap
   - NIM
   - Email
   - Username & Password
   - Fakultas
   - Prodi
4. Klik **"Daftar"**

### 2.2 Login
1. Masukkan Username/Email dan Password
2. Klik **"Masuk"**

### 2.3 Mengajukan Magang
1. Dari Dashboard, klik menu **"Pengajuan"**
2. Klik tombol **"+ Ajukan Magang"**
3. Isi formulir:
   - Nama Instansi (atau pilih dari daftar)
   - Posisi yang dilamar
   - Tanggal Mulai & Selesai
   - Durasi (bulan)
   - Keterangan tambahan (opsional)
4. Klik **"Kirim Pengajuan"**
5. Tunggu verifikasi dari Admin Fakultas dan Dosen Pembimbing

### 2.4 Cek Status Pengajuan
1. Buka menu **"Pengajuan"**
2. Lihat status di kartu pengajuan:
   - 🟠 **Diajukan** - Menunggu review
   - 🟢 **Disetujui** - Diterima, siap magang
   - 🔴 **Ditolak** - Ditolak, lihat alasan
   - 🔵 **Selesai** - Magang telah selesai

### 2.5 Input Kehadiran (Check-in)
1. Pastikan GPS aktif
2. Buka menu **"Kehadiran"**
3. Klik tombol **"Check-in"**
4. Sistem akan merekam waktu dan lokasi Anda
5. Di akhir hari, lakukan **"Check-out"**

### 2.6 Membuat Laporan Harian
1. Buka menu **"Laporan"**
2. Klik **"+ Buat Laporan"**
3. Pilih jenis: **Harian** atau **Monitoring**
4. Isi kegiatan yang dilakukan
5. Klik **"Simpan"**

### 2.7 Mengajukan Bimbingan
1. Buka menu **"Bimbingan"**
2. Klik **"+ Ajukan Bimbingan"**
3. Isi:
   - Topik bimbingan
   - Deskripsi masalah
   - Catatan tambahan (opsional)
4. Tunggu dosen menjadwalkan waktu

### 2.8 Melihat Nilai
1. Buka menu **"Nilai"**
2. Lihat nilai dari Dosen Pembimbing dan Instansi

---

## 3. Panduan untuk Siswa (PKL)

> Alur sama dengan Mahasiswa, dengan perbedaan:
> - Role: **Siswa**
> - Data tambahan: NISN, Kelas, Jurusan
> - Pembimbing: **Guru** (bukan Dosen)
> - Jenis Pengajuan: **PKL** (bukan Magang)

---

## 4. Panduan untuk Dosen Pembimbing

### 4.1 Dashboard
Setelah login, dosen akan melihat:
- Jumlah mahasiswa bimbingan
- Pengajuan baru yang perlu diverifikasi
- Laporan yang perlu di-review

### 4.2 Verifikasi Pengajuan
1. Buka menu **"Verifikasi"**
2. Klik pengajuan untuk melihat detail
3. Pilih **"Setujui"** atau **"Tolak"** (dengan alasan)

### 4.3 Melihat Kehadiran Mahasiswa
1. Buka menu **"Monitoring"**
2. Pilih mahasiswa dari daftar
3. Lihat riwayat kehadiran lengkap

### 4.4 Review Laporan
1. Buka menu **"Laporan"**
2. Pilih mahasiswa
3. Baca laporan dan berikan komentar
4. Setujui atau minta revisi

### 4.5 Menjadwalkan Bimbingan
1. Buka menu **"Bimbingan"** → Tab "Menunggu"
2. Klik permintaan bimbingan
3. Klik **"Jadwalkan"**
4. Pilih tanggal, waktu, dan lokasi
5. Simpan

### 4.6 Memberikan Nilai
1. Buka menu **"Penilaian"**
2. Pilih mahasiswa yang sudah selesai magang
3. Isi komponen nilai:
   - Kehadiran
   - Kinerja
   - Sikap
   - Laporan
4. Klik **"Simpan Nilai"**

---

## 5. Panduan untuk Guru Pembimbing

> Alur sama dengan Dosen Pembimbing.
> Perbedaan hanya pada target siswa PKL (bukan mahasiswa magang).

---

## 6. Panduan untuk Instansi

### 6.1 Registrasi Akun Instansi
1. Pilih role **"Instansi"** saat daftar
2. Isi data:
   - Nama Instansi
   - Alamat Lengkap
   - Kontak (Telepon/Email)
   - Bidang Usaha

### 6.2 Konfirmasi Penerimaan Peserta
1. Buka menu **"Pengajuan Masuk"**
2. Lihat daftar mahasiswa/siswa yang mengajukan
3. Klik **"Terima"** atau **"Tolak"**

### 6.3 Melihat Kehadiran Peserta
1. Buka menu **"Monitoring"**
2. Pilih peserta
3. Lihat data check-in/check-out harian

### 6.4 Memberikan Penilaian
1. Buka menu **"Penilaian"**
2. Pilih peserta yang sudah selesai
3. Isi nilai industri
4. Simpan

---

## 7. Panduan untuk Admin Fakultas

### 7.1 Dashboard
Menampilkan:
- Total pengajuan magang di fakultas
- Statistik (Diajukan, Disetujui, Ditolak, Selesai)
- Pengajuan terbaru

### 7.2 Verifikasi Pengajuan
1. Buka menu **"Verifikasi"**
2. Review pengajuan dari mahasiswa fakultas Anda
3. Pilih dosen pembimbing dari dropdown
4. Klik **"Setujui"** atau **"Tolak"**

### 7.3 Kelola Dosen Pembimbing
1. Buka menu **"Dosen"**
2. Lihat daftar dosen di fakultas Anda
3. Klik **"+ Tambah"** untuk menambah dosen baru
4. Isi data dosen dan klik Simpan

### 7.4 Monitoring Kehadiran
1. Buka menu **"Kehadiran"**
2. Pilih mahasiswa dari daftar
3. Lihat detail absensi

---

## 8. Panduan untuk Admin Sekolah

> Alur sama dengan Admin Fakultas.
> Perbedaan:
> - Mengelola data **Guru Pembimbing** (bukan Dosen)
> - Scope: **PKL** (bukan Magang)
> - Target: **Siswa** (bukan Mahasiswa)

---

## 9. Panduan untuk Super Admin

### 9.1 Dashboard
Menampilkan statistik global seluruh sistem.

### 9.2 Kelola Pengguna
1. Buka menu **"Kelola User"**
2. Lihat daftar semua user
3. Filter berdasarkan role
4. Tambah, Edit, atau Hapus user

### 9.3 Konfigurasi Sistem
- Kelola data Fakultas/Jurusan
- Kelola data Instansi terdaftar
- Lihat log aktivitas

---

## Troubleshooting

### Tidak bisa login
- Pastikan username/password benar
- Cek koneksi internet
- Restart aplikasi

### Check-in gagal
- Aktifkan GPS/Lokasi di perangkat
- Berikan izin lokasi ke aplikasi
- Pastikan berada di radius instansi (jika ada batas jarak)

### Laporan tidak tersimpan
- Pastikan semua field wajib terisi
- Cek koneksi internet
- Coba lagi setelah beberapa saat

---

## Kontak Support

Jika menemukan kendala:
- Email: [email_developer@email.com]
- WhatsApp: [nomor_whatsapp]

---

**Versi Dokumen**: 1.0  
**Terakhir Diperbarui**: Januari 2026
