-- ==============================================
-- Document Generation Migration
-- UMPAR Magang & PKL System
-- ==============================================
-- Adds field for tracking when documents are auto-generated

-- Add document_generated_at column to pengajuan table
ALTER TABLE pengajuan 
    ADD COLUMN document_generated_at DATETIME NULL COMMENT 'Timestamp when documents were auto-generated';

-- Create uploads directory structure index
-- (The actual directories are created by PHP)
