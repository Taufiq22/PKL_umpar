-- ==============================================
-- GPS Fields Migration for Kehadiran Table
-- UMPAR Magang & PKL System
-- ==============================================
-- Note: Run this AFTER kehadiran table exists

-- Add GPS fields for check-in
ALTER TABLE kehadiran 
    ADD COLUMN latitude_checkin DECIMAL(10,8) NULL COMMENT 'Latitude saat check-in',
    ADD COLUMN longitude_checkin DECIMAL(11,8) NULL COMMENT 'Longitude saat check-in',
    ADD COLUMN akurasi_checkin INT NULL COMMENT 'Akurasi GPS dalam meter saat check-in',
    ADD COLUMN jarak_checkin INT NULL COMMENT 'Jarak dari lokasi instansi dalam meter saat check-in',
    ADD COLUMN lokasi_valid_checkin TINYINT(1) DEFAULT 1 COMMENT '1 = dalam radius, 0 = di luar radius';

-- Add GPS fields for check-out
ALTER TABLE kehadiran 
    ADD COLUMN latitude_checkout DECIMAL(10,8) NULL COMMENT 'Latitude saat check-out',
    ADD COLUMN longitude_checkout DECIMAL(11,8) NULL COMMENT 'Longitude saat check-out',
    ADD COLUMN akurasi_checkout INT NULL COMMENT 'Akurasi GPS dalam meter saat check-out',
    ADD COLUMN jarak_checkout INT NULL COMMENT 'Jarak dari lokasi instansi dalam meter saat check-out',
    ADD COLUMN lokasi_valid_checkout TINYINT(1) DEFAULT 1 COMMENT '1 = dalam radius, 0 = di luar radius';

-- ==============================================
-- Add GPS coordinates to Instansi table (jika belum ada)
-- ==============================================

-- Try adding columns - ignore if already exist
-- Run these one by one if you get "Duplicate column" error

ALTER TABLE instansi ADD COLUMN latitude DECIMAL(10,8) NULL COMMENT 'Latitude lokasi instansi';
ALTER TABLE instansi ADD COLUMN longitude DECIMAL(11,8) NULL COMMENT 'Longitude lokasi instansi';
ALTER TABLE instansi ADD COLUMN radius_absensi INT DEFAULT 100 COMMENT 'Radius valid untuk absensi dalam meter';

-- ==============================================
-- Sample: Update instansi with GPS coordinates (Parepare)
-- ==============================================

UPDATE instansi 
SET latitude = -4.0135, 
    longitude = 119.6255, 
    radius_absensi = 100 
WHERE latitude IS NULL;

-- ==============================================
-- ALTERNATIVE: If columns already exist, use this instead:
-- ==============================================
-- 
-- If you get "Duplicate column name" error, that means columns already exist.
-- That's OK - the migration was partially applied before.
-- Just skip to the UPDATE statement at the end.
