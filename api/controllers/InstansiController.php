<?php
/**
 * Instansi Controller
 * Untuk mengambil daftar instansi yang terdaftar
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class InstansiController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all registered instansi
     */
    public function getAll() {
        // No auth required - public list for pengajuan dropdown
        
        $stmt = $this->db->prepare("
            SELECT 
                i.id_instansi,
                i.nama_instansi,
                i.alamat,
                i.bidang,
                i.kontak,
                u.email
            FROM instansi i
            JOIN user u ON i.id_user = u.id_user
            WHERE u.is_active = 1
            ORDER BY i.nama_instansi ASC
        ");
        $stmt->execute();
        $instansi = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        successResponse('Data instansi berhasil diambil', $instansi);
    }

    /**
     * Get instansi by ID
     */
    public function getById($id) {
        $stmt = $this->db->prepare("
            SELECT 
                i.id_instansi,
                i.nama_instansi,
                i.alamat,
                i.bidang,
                i.kontak,
                u.email,
                u.nama_lengkap as nama_penanggung_jawab
            FROM instansi i
            JOIN user u ON i.id_user = u.id_user
            WHERE i.id_instansi = ?
        ");
        $stmt->execute([$id]);
        $instansi = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$instansi) {
            errorResponse('Instansi tidak ditemukan', null, 404);
        }
        
        successResponse('Detail instansi berhasil diambil', $instansi);
    }
}
