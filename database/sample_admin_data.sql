-- ==============================================
-- Sample Admin Data for Testing
-- UMPAR Magang & PKL System
-- ==============================================

-- Note: Passwords are hashed using bcrypt
-- Default password for all test accounts: "password123"
-- Hash: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi

-- ==============================================
-- 1. SAMPLE ADMIN FAKULTAS
-- ==============================================

-- User account for Admin Fakultas Teknik
INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    'admin_fti', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Admin Fakultas Teknik Informatika', 
    'admin.fti@umpar.ac.id', 
    'admin_fakultas', 
    1, 
    NOW()
);

-- Admin Fakultas profile
INSERT INTO admin_fakultas (id_user, kode_fakultas, nama_fakultas, jabatan, created_at)
VALUES (
    LAST_INSERT_ID(), 
    'FTI', 
    'Fakultas Teknik Informatika', 
    'Koordinator Magang',
    NOW()
);

-- User account for Admin Fakultas Ekonomi
INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    'admin_feb', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Admin Fakultas Ekonomi dan Bisnis', 
    'admin.feb@umpar.ac.id', 
    'admin_fakultas', 
    1, 
    NOW()
);

INSERT INTO admin_fakultas (id_user, kode_fakultas, nama_fakultas, jabatan, created_at)
VALUES (
    LAST_INSERT_ID(), 
    'FEB', 
    'Fakultas Ekonomi dan Bisnis', 
    'Koordinator Magang',
    NOW()
);

-- ==============================================
-- 2. SAMPLE ADMIN SEKOLAH
-- ==============================================

-- User account for Admin SMKN 1
INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    'admin_smkn1', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Admin SMKN 1 Parepare', 
    'admin@smkn1-parepare.sch.id', 
    'admin_sekolah', 
    1, 
    NOW()
);

INSERT INTO admin_sekolah (id_user, npsn, nama_sekolah, jenis_sekolah, alamat, kabupaten, provinsi, created_at)
VALUES (
    LAST_INSERT_ID(), 
    '40301234', 
    'SMKN 1 Parepare', 
    'SMK',
    'Jl. Pendidikan No. 1',
    'Parepare',
    'Sulawesi Selatan',
    NOW()
);

-- User account for Admin SMAN 2
INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    'admin_sman2', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Admin SMAN 2 Parepare', 
    'admin@sman2-parepare.sch.id', 
    'admin_sekolah', 
    1, 
    NOW()
);

INSERT INTO admin_sekolah (id_user, npsn, nama_sekolah, jenis_sekolah, alamat, kabupaten, provinsi, created_at)
VALUES (
    LAST_INSERT_ID(), 
    '40305678', 
    'SMAN 2 Parepare', 
    'SMA',
    'Jl. Ilmu Pengetahuan No. 2',
    'Parepare',
    'Sulawesi Selatan',
    NOW()
);

-- ==============================================
-- 3. SAMPLE MAHASISWA (for testing)
-- ==============================================

INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    '2021001', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Budi Santoso', 
    'budi.santoso@student.umpar.ac.id', 
    'mahasiswa', 
    1, 
    NOW()
);

INSERT INTO mahasiswa (id_user, nim, prodi, fakultas, semester, ipk, created_at)
VALUES (
    LAST_INSERT_ID(),
    '2021001',
    'Teknik Informatika',
    'Fakultas Teknik Informatika',
    6,
    3.75,
    NOW()
);

-- ==============================================
-- 4. SAMPLE SISWA (for testing)
-- ==============================================

INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    '0012345678', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Ani Rahmawati', 
    'ani.rahmawati@student.smkn1.sch.id', 
    'siswa', 
    1, 
    NOW()
);

INSERT INTO siswa (id_user, nisn, kelas, jurusan, nama_sekolah, created_at)
VALUES (
    LAST_INSERT_ID(),
    '0012345678',
    'XII',
    'Rekayasa Perangkat Lunak',
    'SMKN 1 Parepare',
    NOW()
);

-- ==============================================
-- 5. SAMPLE DOSEN PEMBIMBING
-- ==============================================

INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    '0987654321', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Dr. Ahmad Wijaya, M.Kom', 
    'ahmad.wijaya@umpar.ac.id', 
    'dosen', 
    1, 
    NOW()
);

INSERT INTO dosen_pembimbing (id_user, nidn, prodi, fakultas, bidang_keahlian, created_at)
VALUES (
    LAST_INSERT_ID(),
    '0987654321',
    'Teknik Informatika',
    'Fakultas Teknik Informatika',
    'Software Engineering',
    NOW()
);

-- ==============================================
-- 6. SAMPLE INSTANSI
-- ==============================================

INSERT INTO user (username, password, nama_lengkap, email, role, is_active, created_at) 
VALUES (
    'ptmaju', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'PT Maju Bersama', 
    'hrd@majubersama.co.id', 
    'instansi', 
    1, 
    NOW()
);

INSERT INTO instansi (id_user, nama_instansi, jenis_instansi, alamat, kota, telepon, email, latitude, longitude, created_at)
VALUES (
    LAST_INSERT_ID(),
    'PT Maju Bersama',
    'Perusahaan',
    'Jl. Industri No. 100',
    'Parepare',
    '0421-12345',
    'hrd@majubersama.co.id',
    -4.0135,
    119.6255,
    NOW()
);

-- ==============================================
-- TEST ACCOUNTS SUMMARY
-- ==============================================
-- Username: admin_fti    | Password: password123 | Role: admin_fakultas
-- Username: admin_feb    | Password: password123 | Role: admin_fakultas
-- Username: admin_smkn1  | Password: password123 | Role: admin_sekolah
-- Username: admin_sman2  | Password: password123 | Role: admin_sekolah
-- Username: 2021001      | Password: password123 | Role: mahasiswa (login with NIM)
-- Username: 0012345678   | Password: password123 | Role: siswa (login with NISN)
-- Username: 0987654321   | Password: password123 | Role: dosen (login with NIDN)
-- Username: ptmaju       | Password: password123 | Role: instansi
