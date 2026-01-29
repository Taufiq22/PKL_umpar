-- =====================================================
-- ALTER USER ROLE ENUM
-- UMPAR Magang & PKL System
-- =====================================================
-- Run this migration to add admin_fakultas and admin_sekolah roles

-- Alter user table to include new admin roles
ALTER TABLE `user` MODIFY COLUMN `role` 
ENUM('admin','admin_fakultas','admin_sekolah','mahasiswa','siswa','dosen','guru','instansi') 
NOT NULL;

-- =====================================================
-- VERIFY CHANGE
-- =====================================================
-- Check the column definition
-- SHOW COLUMNS FROM `user` LIKE 'role';
