-- ==============================================
-- Database Optimization & Indexes
-- UMPAR Magang & PKL System
-- ==============================================
-- Run this after all migrations to optimize performance

-- ==============================================
-- INDEXES FOR PENGAJUAN TABLE
-- ==============================================

-- Status indexes for faster filtering
CREATE INDEX IF NOT EXISTS idx_pengajuan_status ON pengajuan(status_pengajuan);
CREATE INDEX IF NOT EXISTS idx_pengajuan_jenis ON pengajuan(jenis_pengajuan);
CREATE INDEX IF NOT EXISTS idx_pengajuan_tanggal ON pengajuan(tanggal_mulai, tanggal_selesai);

-- Foreign key indexes
CREATE INDEX IF NOT EXISTS idx_pengajuan_mahasiswa ON pengajuan(id_mahasiswa);
CREATE INDEX IF NOT EXISTS idx_pengajuan_siswa ON pengajuan(id_siswa);
CREATE INDEX IF NOT EXISTS idx_pengajuan_instansi ON pengajuan(id_instansi);
CREATE INDEX IF NOT EXISTS idx_pengajuan_dosen ON pengajuan(id_dosen_pembimbing);
CREATE INDEX IF NOT EXISTS idx_pengajuan_guru ON pengajuan(id_guru_pembimbing);

-- ==============================================
-- INDEXES FOR KEHADIRAN TABLE
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_kehadiran_pengajuan ON kehadiran(id_pengajuan);
CREATE INDEX IF NOT EXISTS idx_kehadiran_tanggal ON kehadiran(tanggal);
CREATE INDEX IF NOT EXISTS idx_kehadiran_status ON kehadiran(status_kehadiran);

-- Composite index for daily check
CREATE INDEX IF NOT EXISTS idx_kehadiran_daily ON kehadiran(id_pengajuan, tanggal);

-- ==============================================
-- INDEXES FOR LAPORAN TABLE
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_laporan_pengajuan ON laporan(id_pengajuan);
CREATE INDEX IF NOT EXISTS idx_laporan_jenis ON laporan(jenis_laporan);
CREATE INDEX IF NOT EXISTS idx_laporan_status ON laporan(status);
CREATE INDEX IF NOT EXISTS idx_laporan_tanggal ON laporan(tanggal_submit);

-- ==============================================
-- INDEXES FOR BIMBINGAN TABLE
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_bimbingan_pengajuan ON bimbingan(id_pengajuan);
CREATE INDEX IF NOT EXISTS idx_bimbingan_status ON bimbingan(status);
CREATE INDEX IF NOT EXISTS idx_bimbingan_jadwal ON bimbingan(tanggal_jadwal);

-- ==============================================
-- INDEXES FOR USER TABLE
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_user_role ON user(role);
CREATE INDEX IF NOT EXISTS idx_user_active ON user(is_active);
CREATE INDEX IF NOT EXISTS idx_user_email ON user(email);

-- ==============================================
-- INDEXES FOR NOTIFIKASI TABLE
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_notifikasi_user ON notifikasi(id_user);
CREATE INDEX IF NOT EXISTS idx_notifikasi_dibaca ON notifikasi(is_read);
CREATE INDEX IF NOT EXISTS idx_notifikasi_tanggal ON notifikasi(created_at);

-- ==============================================
-- OPTIMIZE TABLES
-- ==============================================

OPTIMIZE TABLE user;
OPTIMIZE TABLE pengajuan;
OPTIMIZE TABLE kehadiran;
OPTIMIZE TABLE laporan;
OPTIMIZE TABLE notifikasi;

-- ==============================================
-- ANALYZE TABLES (Update statistics for query optimizer)
-- ==============================================

ANALYZE TABLE user;
ANALYZE TABLE pengajuan;
ANALYZE TABLE kehadiran;
ANALYZE TABLE laporan;
ANALYZE TABLE notifikasi;
