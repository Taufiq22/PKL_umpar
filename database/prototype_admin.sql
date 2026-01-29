-- ==============================================
-- Prototype Admin Accounts
-- Username: 1 = Admin Fakultas
-- Username: 2 = Admin Sekolah
-- Password: 1 (for both)
-- ==============================================

-- Password hash for "1" using bcrypt
-- Generated with: password_hash('1', PASSWORD_DEFAULT)
SET @password_hash = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

-- Insert Admin Fakultas user
INSERT INTO `user` (`username`, `password`, `nama_lengkap`, `email`, `role`, `is_active`) 
VALUES ('1', @password_hash, 'Admin Fakultas Prototype', 'adminfakultas@umpar.ac.id', 'admin_fakultas', 1);

SET @admin_fakultas_id = LAST_INSERT_ID();

-- Insert Admin Fakultas detail
INSERT INTO `admin_fakultas` (`id_user`, `nama`, `fakultas`, `jabatan`) 
VALUES (@admin_fakultas_id, 'Admin Fakultas Prototype', 'Fakultas Teknik', 'Koordinator Magang');

-- Insert Admin Sekolah user
INSERT INTO `user` (`username`, `password`, `nama_lengkap`, `email`, `role`, `is_active`) 
VALUES ('2', @password_hash, 'Admin Sekolah Prototype', 'adminsekolah@umpar.ac.id', 'admin_sekolah', 1);

SET @admin_sekolah_id = LAST_INSERT_ID();

-- Insert Admin Sekolah detail
INSERT INTO `admin_sekolah` (`id_user`, `nama`, `nama_sekolah`, `jenis_sekolah`, `jabatan`) 
VALUES (@admin_sekolah_id, 'Admin Sekolah Prototype', 'SMK Negeri 1 Parepare', 'SMK', 'Koordinator PKL');

-- Verify inserted data
SELECT 'Admin Fakultas' as Type, u.id_user, u.username, u.nama_lengkap, u.role, af.fakultas 
FROM user u 
JOIN admin_fakultas af ON u.id_user = af.id_user 
WHERE u.username = '1'

UNION ALL

SELECT 'Admin Sekolah' as Type, u.id_user, u.username, u.nama_lengkap, u.role, asek.nama_sekolah 
FROM user u 
JOIN admin_sekolah asek ON u.id_user = asek.id_user 
WHERE u.username = '2';
