-- =====================================================
-- KEHADIRAN (Attendance) TABLE
-- UMPAR Magang & PKL System
-- =====================================================

-- Create kehadiran table for daily attendance tracking
CREATE TABLE IF NOT EXISTS `kehadiran` (
    `id_kehadiran` INT NOT NULL AUTO_INCREMENT,
    `id_pengajuan` INT NOT NULL,
    `tanggal` DATE NOT NULL,
    `status_kehadiran` ENUM('Hadir', 'Izin', 'Sakit', 'Alpha') NOT NULL DEFAULT 'Hadir',
    `jam_masuk` TIME DEFAULT NULL,
    `jam_keluar` TIME DEFAULT NULL,
    `keterangan` TEXT,
    `lokasi_checkin` VARCHAR(255) DEFAULT NULL,
    `foto_bukti` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_kehadiran`),
    UNIQUE KEY `unique_attendance` (`id_pengajuan`, `tanggal`),
    KEY `idx_tanggal` (`tanggal`),
    KEY `idx_status` (`status_kehadiran`),
    CONSTRAINT `kehadiran_ibfk_1` FOREIGN KEY (`id_pengajuan`) REFERENCES `pengajuan` (`id_pengajuan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- INSERT INTO `kehadiran` (`id_pengajuan`, `tanggal`, `status_kehadiran`, `jam_masuk`, `jam_keluar`, `keterangan`) VALUES
-- (1, CURDATE(), 'Hadir', '08:00:00', '17:00:00', 'Masuk tepat waktu'),
-- (1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Hadir', '08:15:00', '17:00:00', NULL),
-- (1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Izin', NULL, NULL, 'Keperluan keluarga'),
-- (1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Sakit', NULL, NULL, 'Demam');
