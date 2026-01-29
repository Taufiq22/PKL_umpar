-- ========================================
-- RESET PASSWORD ADMIN FAKULTAS & ADMIN SEKOLAH
-- ========================================
-- Password baru: admin123
-- Hash bcrypt: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi (ini hash dari 'password')
-- Atau gunakan hash di bawah untuk 'admin123'

-- Generate hash untuk 'admin123' (copy dari PHP password_hash output)
-- Contoh hash: $2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4a0aTrWC9FX3rP6i

-- ========================================
-- OPSI 1: Reset dengan password 'password' (hash standar Laravel)
-- ========================================
UPDATE user 
SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE role IN ('admin_fakultas', 'admin_sekolah');

-- ========================================
-- OPSI 2: Reset HANYA Admin Fakultas
-- ========================================
-- UPDATE user 
-- SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
-- WHERE role = 'admin_fakultas';

-- ========================================
-- OPSI 3: Reset HANYA Admin Sekolah  
-- ========================================
-- UPDATE user 
-- SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
-- WHERE role = 'admin_sekolah';

-- ========================================
-- OPSI 4: Reset berdasarkan username tertentu
-- ========================================
-- UPDATE user 
-- SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
-- WHERE username IN ('admin_fti', 'admin_feb', 'admin_smkn1', 'admin_sman2');

-- ========================================
-- OPSI 5: Reset dengan password MD5 (legacy, tidak direkomendasikan)
-- ========================================
-- UPDATE user 
-- SET password = MD5('admin123')
-- WHERE role IN ('admin_fakultas', 'admin_sekolah');

-- ========================================
-- VERIFIKASI: Lihat daftar admin yang sudah direset
-- ========================================
SELECT 
    u.id_user,
    u.username,
    u.nama_lengkap,
    u.role,
    u.email,
    u.is_active,
    CASE 
        WHEN u.role = 'admin_fakultas' THEN af.fakultas
        WHEN u.role = 'admin_sekolah' THEN asek.nama_sekolah
        ELSE NULL
    END AS unit_kerja
FROM user u
LEFT JOIN admin_fakultas af ON u.id_user = af.id_user
LEFT JOIN admin_sekolah asek ON u.id_user = asek.id_user
WHERE u.role IN ('admin_fakultas', 'admin_sekolah')
ORDER BY u.role, u.id_user;

-- ========================================
-- INFO PASSWORD
-- ========================================
-- Hash bcrypt dari 'password': $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- 
-- Untuk generate hash baru, jalankan PHP:
-- echo password_hash('password_baru_anda', PASSWORD_BCRYPT);
--
-- Daftar Admin setelah reset:
-- | Username     | Role           | Password Baru |
-- |-------------|----------------|---------------|
-- | 1           | admin_fakultas | password      |
-- | admin_fti   | admin_fakultas | password      |
-- | admin_feb   | admin_fakultas | password      |
-- | 2           | admin_sekolah  | password      |
-- | admin_smkn1 | admin_sekolah  | password      |
-- | admin_sman2 | admin_sekolah  | password      |
