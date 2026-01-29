<?php
/**
 * Pembimbing Controller
 * Untuk mengambil daftar dosen dan guru pembimbing
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class PembimbingController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all dosen pembimbing
     */
    public function getDosenPembimbing() {
        requireAuth();
        
        $stmt = $this->db->prepare("
            SELECT 
                d.id_dosen,
                d.nidn,
                d.prodi,
                d.bidang,
                u.nama_lengkap,
                u.email
            FROM dosen_pembimbing d
            JOIN user u ON d.id_user = u.id_user
            WHERE u.is_active = 1
            ORDER BY u.nama_lengkap ASC
        ");
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        successResponse('Data dosen pembimbing berhasil diambil', $result);
    }

    /**
     * Get all guru pembimbing
     */
    public function getGuruPembimbing() {
        requireAuth();
        
        $stmt = $this->db->prepare("
            SELECT 
                g.id_guru,
                g.nip,
                g.sekolah,
                g.bidang,
                u.nama_lengkap,
                u.email
            FROM guru_pembimbing g
            JOIN user u ON g.id_user = u.id_user
            WHERE u.is_active = 1
            ORDER BY u.nama_lengkap ASC
        ");
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        successResponse('Data guru pembimbing berhasil diambil', $result);
    }

    /**
     * Get all pembimbing (both dosen and guru)
     */
    public function getAll() {
        requireAuth();
        
        // Get dosen
        $stmt = $this->db->prepare("
            SELECT 
                d.id_dosen as id,
                'dosen' as tipe,
                d.nidn as nomor_identitas,
                d.prodi as institusi,
                d.bidang,
                u.nama_lengkap,
                u.email
            FROM dosen_pembimbing d
            JOIN user u ON d.id_user = u.id_user
            WHERE u.is_active = 1
        ");
        $stmt->execute();
        $dosen = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get guru
        $stmt = $this->db->prepare("
            SELECT 
                g.id_guru as id,
                'guru' as tipe,
                g.nip as nomor_identitas,
                g.sekolah as institusi,
                g.bidang,
                u.nama_lengkap,
                u.email
            FROM guru_pembimbing g
            JOIN user u ON g.id_user = u.id_user
            WHERE u.is_active = 1
        ");
        $stmt->execute();
        $guru = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $result = [
            'dosen' => $dosen,
            'guru' => $guru,
        ];
        
        successResponse('Data pembimbing berhasil diambil', $result);
    }
}
