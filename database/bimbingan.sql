-- =====================================================
-- BIMBINGAN (Guidance Session) TABLE
-- UMPAR Magang & PKL System
-- =====================================================

-- Create bimbingan table for guidance session management
CREATE TABLE IF NOT EXISTS `bimbingan` (
    `id_bimbingan` INT NOT NULL AUTO_INCREMENT,
    `id_pengajuan` INT NOT NULL,
    `topik_bimbingan` VARCHAR(200) NOT NULL,
    `deskripsi_masalah` TEXT NOT NULL,
    `tanggal_pengajuan` DATE NOT NULL,
    `status_bimbingan` ENUM('Diajukan', 'Dijadwalkan', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Diajukan',
    `tanggal_bimbingan` DATETIME DEFAULT NULL,
    `lokasi_bimbingan` VARCHAR(100) DEFAULT NULL,
    `catatan_mahasiswa` TEXT,
    `feedback_pembimbing` TEXT,
    `rating` TINYINT DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_bimbingan`),
    KEY `idx_status` (`status_bimbingan`),
    KEY `idx_tanggal` (`tanggal_pengajuan`),
    KEY `id_pengajuan` (`id_pengajuan`),
    CONSTRAINT `bimbingan_ibfk_1` FOREIGN KEY (`id_pengajuan`) REFERENCES `pengajuan` (`id_pengajuan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- INSERT INTO `bimbingan` (`id_pengajuan`, `topik_bimbingan`, `deskripsi_masalah`, `tanggal_pengajuan`, `status_bimbingan`) VALUES
-- (1, 'Kesulitan Integrasi API', 'Mengalami kesulitan dalam mengintegrasikan REST API dengan frontend Flutter', CURDATE(), 'Diajukan'),
-- (1, 'Review Progress Mingguan', 'Membahas progress minggu pertama magang', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Selesai');
