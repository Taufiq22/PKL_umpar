-- =====================================================
-- ADMIN ROLES ENHANCEMENT
-- UMPAR Magang & PKL System
-- =====================================================

-- Note: The main 'user' table uses enum role:
-- ENUM('admin','mahasiswa','siswa','dosen','guru','instansi')
-- Admin fakultas and admin sekolah are sub-types of admin role

-- =====================================================
-- ADMIN FAKULTAS TABLE
-- For faculty/department level administration
-- Links to user table with admin role
-- =====================================================

CREATE TABLE IF NOT EXISTS `admin_fakultas` (
    `id_admin_fakultas` INT NOT NULL AUTO_INCREMENT,
    `id_user` INT NOT NULL,
    `nama` VARCHAR(100) NOT NULL,
    `nip` VARCHAR(20) DEFAULT NULL,
    `fakultas` VARCHAR(100) NOT NULL,
    `program_studi` VARCHAR(100) DEFAULT NULL,
    `jabatan` VARCHAR(100) DEFAULT NULL,
    `email` VARCHAR(100) DEFAULT NULL,
    `telepon` VARCHAR(20) DEFAULT NULL,
    `foto` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_admin_fakultas`),
    UNIQUE KEY `id_user` (`id_user`),
    KEY `idx_fakultas` (`fakultas`),
    CONSTRAINT `admin_fakultas_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- ADMIN SEKOLAH TABLE
-- For school level PKL administration
-- Links to user table with admin role
-- =====================================================

CREATE TABLE IF NOT EXISTS `admin_sekolah` (
    `id_admin_sekolah` INT NOT NULL AUTO_INCREMENT,
    `id_user` INT NOT NULL,
    `nama` VARCHAR(100) NOT NULL,
    `nip` VARCHAR(20) DEFAULT NULL,
    `nama_sekolah` VARCHAR(100) NOT NULL,
    `alamat_sekolah` TEXT,
    `jenis_sekolah` ENUM('SMK', 'SMA', 'MA') NOT NULL DEFAULT 'SMK',
    `jabatan` VARCHAR(100) DEFAULT NULL,
    `email` VARCHAR(100) DEFAULT NULL,
    `telepon` VARCHAR(20) DEFAULT NULL,
    `foto` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_admin_sekolah`),
    UNIQUE KEY `id_user` (`id_user`),
    KEY `idx_sekolah` (`nama_sekolah`),
    CONSTRAINT `admin_sekolah_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- FAKULTAS REFERENCE TABLE (Optional)
-- =====================================================

CREATE TABLE IF NOT EXISTS `fakultas` (
    `id_fakultas` INT NOT NULL AUTO_INCREMENT,
    `nama_fakultas` VARCHAR(100) NOT NULL,
    `kode_fakultas` VARCHAR(10) DEFAULT NULL,
    `dekan` VARCHAR(100) DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_fakultas`),
    UNIQUE KEY `nama_fakultas` (`nama_fakultas`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert sample fakultas for UMPAR
INSERT IGNORE INTO `fakultas` (`nama_fakultas`, `kode_fakultas`) VALUES
('Fakultas Teknik', 'FT'),
('Fakultas Ekonomi dan Bisnis', 'FEB'),
('Fakultas Keguruan dan Ilmu Pendidikan', 'FKIP'),
('Fakultas Pertanian', 'FP'),
('Fakultas Ilmu Kesehatan', 'FIK'),
('Fakultas Agama Islam', 'FAI');
