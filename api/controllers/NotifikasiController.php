<?php
/**
 * Notifikasi Controller
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class NotifikasiController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all notifikasi for current user
     */
    public function getAll() {
        $authUser = requireAuth();
        
        // Note: Assuming notifikasi table exists (we added it in review #1)
        // If table doesn't exist, return empty array
        try {
            $stmt = $this->db->prepare("
                SELECT * FROM notifikasi 
                WHERE id_user = ? 
                ORDER BY created_at DESC
            ");
            $stmt->execute([$authUser['user_id']]);
            successResponse('Data notifikasi berhasil diambil', $stmt->fetchAll());
        } catch (Exception $e) {
            // Table might not exist yet
            successResponse('Data notifikasi berhasil diambil', []);
        }
    }

    /**
     * Mark notification as read
     */
    public function markAsRead($id) {
        $authUser = requireAuth();
        
        $stmt = $this->db->prepare("
            UPDATE notifikasi SET dibaca = 1 
            WHERE id_notifikasi = ? AND id_user = ?
        ");
        $stmt->execute([$id, $authUser['user_id']]);
        
        successResponse('Notifikasi ditandai sudah dibaca');
    }

    /**
     * Delete notification
     */
    public function delete($id) {
        $authUser = requireAuth();
        
        $stmt = $this->db->prepare("
            DELETE FROM notifikasi 
            WHERE id_notifikasi = ? AND id_user = ?
        ");
        $stmt->execute([$id, $authUser['user_id']]);
        
        successResponse('Notifikasi berhasil dihapus');
    }

    /**
     * Create notification (internal use)
     */
    public static function create($idUser, $judul, $pesan, $tipe = 'info') {
        try {
            $db = getDB();
            $stmt = $db->prepare("
                INSERT INTO notifikasi (id_user, judul, pesan, tipe, dibaca, created_at) 
                VALUES (?, ?, ?, ?, 0, NOW())
            ");
            $stmt->execute([$idUser, $judul, $pesan, $tipe]);
            return true;
        } catch (Exception $e) {
            return false;
        }
    }
}
