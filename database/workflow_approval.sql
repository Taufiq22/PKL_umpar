-- ==============================================
-- Multi-Level Approval Workflow Migration
-- UMPAR Magang & PKL System
-- ==============================================
-- Adds approval workflow fields to pengajuan table
-- Supports Admin Fakultas approval for Magang
-- Supports Admin Sekolah approval for PKL

-- ==============================================
-- Add approval workflow columns to pengajuan
-- ==============================================

ALTER TABLE pengajuan 
    ADD COLUMN status_admin_fakultas ENUM('pending','approved','rejected') DEFAULT 'pending' COMMENT 'Status approval Admin Fakultas (untuk Magang)',
    ADD COLUMN status_admin_sekolah ENUM('pending','approved','rejected') DEFAULT 'pending' COMMENT 'Status approval Admin Sekolah (untuk PKL)',
    ADD COLUMN approved_by_fakultas INT NULL COMMENT 'ID user Admin Fakultas yang approve',
    ADD COLUMN approved_by_sekolah INT NULL COMMENT 'ID user Admin Sekolah yang approve',
    ADD COLUMN approved_at_fakultas DATETIME NULL COMMENT 'Waktu approval Admin Fakultas',
    ADD COLUMN approved_at_sekolah DATETIME NULL COMMENT 'Waktu approval Admin Sekolah',
    ADD COLUMN catatan_fakultas TEXT NULL COMMENT 'Catatan dari Admin Fakultas',
    ADD COLUMN catatan_sekolah TEXT NULL COMMENT 'Catatan dari Admin Sekolah';

-- ==============================================
-- Add indexes for faster queries
-- ==============================================

CREATE INDEX idx_status_fakultas ON pengajuan(status_admin_fakultas);
CREATE INDEX idx_status_sekolah ON pengajuan(status_admin_sekolah);
CREATE INDEX idx_jenis_pengajuan ON pengajuan(jenis_pengajuan);

-- ==============================================
-- Add foreign key constraints
-- ==============================================

ALTER TABLE pengajuan 
    ADD CONSTRAINT fk_approved_fakultas FOREIGN KEY (approved_by_fakultas) REFERENCES user(id_user) ON DELETE SET NULL,
    ADD CONSTRAINT fk_approved_sekolah FOREIGN KEY (approved_by_sekolah) REFERENCES user(id_user) ON DELETE SET NULL;

-- ==============================================
-- Update existing pengajuan to set proper workflow status
-- ==============================================

-- Untuk pengajuan yang sudah disetujui, set workflow status juga
UPDATE pengajuan 
SET status_admin_fakultas = 'approved' 
WHERE jenis_pengajuan = 'Magang' AND status_pengajuan = 'Disetujui';

UPDATE pengajuan 
SET status_admin_sekolah = 'approved' 
WHERE jenis_pengajuan = 'PKL' AND status_pengajuan = 'Disetujui';

-- ==============================================
-- WORKFLOW LOGIC:
-- ==============================================
-- 
-- MAGANG (Mahasiswa):
--   1. Mahasiswa submit pengajuan → status_pengajuan = 'Diajukan'
--   2. Admin Fakultas review → status_admin_fakultas = 'approved/rejected'
--   3. If approved → status_pengajuan = 'Disetujui', assign pembimbing
--
-- PKL (Siswa):
--   1. Siswa submit pengajuan → status_pengajuan = 'Diajukan'
--   2. Admin Sekolah review → status_admin_sekolah = 'approved/rejected'
--   3. If approved → status_pengajuan = 'Disetujui', assign pembimbing
--
