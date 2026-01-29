<?php
/**
 * BimbinganController - Guidance Session Management
 * UMPAR Magang & PKL System
 * 
 * Handles guidance session requests, scheduling, and feedback
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class BimbinganController {
    
    /**
     * Get all bimbingan sessions (filtered by role)
     * GET /bimbingan
     */
    public function getAll() {
        $user = requireAuth();
        $db = getDB();
        
        $query = "SELECT b.*, 
                    p.jenis_pengajuan,
                    CASE 
                        WHEN p.jenis_pengajuan = 'Magang' THEN um.nama_lengkap
                        ELSE us.nama_lengkap
                    END as nama_peserta,
                    CASE 
                        WHEN p.jenis_pengajuan = 'Magang' THEN m.nim
                        ELSE s.nisn
                    END as nomor_induk,
                    i.nama_instansi
                  FROM bimbingan b
                  JOIN pengajuan p ON b.id_pengajuan = p.id_pengajuan
                  LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                  LEFT JOIN user um ON m.id_user = um.id_user
                  LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                  LEFT JOIN user us ON s.id_user = us.id_user
                  LEFT JOIN instansi i ON p.id_instansi = i.id_instansi";
        
        $params = [];
        
        // Filter by role
        switch ($user['role']) {
            case 'mahasiswa':
                $query .= " WHERE p.id_mahasiswa = (SELECT id_mahasiswa FROM mahasiswa WHERE id_user = ?)";
                $params[] = $user['user_id'];
                break;
            case 'siswa':
                $query .= " WHERE p.id_siswa = (SELECT id_siswa FROM siswa WHERE id_user = ?)";
                $params[] = $user['user_id'];
                break;
            case 'dosen':
                $query .= " WHERE p.id_dosen_pembimbing = (SELECT id_dosen FROM dosen_pembimbing WHERE id_user = ?)";
                $params[] = $user['user_id'];
                break;
            case 'guru':
                $query .= " WHERE p.id_guru_pembimbing = (SELECT id_guru FROM guru_pembimbing WHERE id_user = ?)";
                $params[] = $user['user_id'];
                break;
            case 'admin_fakultas':
                $query .= " WHERE p.jenis_pengajuan = 'Magang' AND m.fakultas = (SELECT fakultas FROM admin_fakultas WHERE id_user = ?)";
                $params[] = $user['user_id'];
                break;
            case 'admin_sekolah':
                 $query .= " WHERE p.jenis_pengajuan = 'PKL' AND s.nama_sekolah = (SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?)";
                 $params[] = $user['user_id'];
                break;
            case 'admin':
                // Admin sees all
                break;
            default:
                return errorResponse('Role tidak memiliki akses', 403);
        }
        
        // Filter by status if provided
        if (isset($_GET['status']) && !empty($_GET['status'])) {
            $query .= empty($params) ? " WHERE" : " AND";
            $query .= " b.status_bimbingan = ?";
            $params[] = $_GET['status'];
        }
        
        $query .= " ORDER BY b.created_at DESC";
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $bimbingan = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($bimbingan, 'Data bimbingan berhasil diambil');
    }
    
    /**
     * Get bimbingan by ID
     * GET /bimbingan/{id}
     */
    public function getById($id) {
        $user = requireAuth();
        $db = getDB();
        
        $query = "SELECT b.*, 
                    p.jenis_pengajuan,
                    CASE 
                        WHEN p.jenis_pengajuan = 'Magang' THEN um.nama_lengkap
                        ELSE us.nama_lengkap
                    END as nama_peserta,
                    CASE 
                        WHEN p.jenis_pengajuan = 'Magang' THEN ud.nama_lengkap
                        ELSE ug.nama_lengkap
                    END as nama_pembimbing,
                    i.nama_instansi
                  FROM bimbingan b
                  JOIN pengajuan p ON b.id_pengajuan = p.id_pengajuan
                  LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                  LEFT JOIN user um ON m.id_user = um.id_user
                  LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                  LEFT JOIN user us ON s.id_user = us.id_user
                  LEFT JOIN dosen_pembimbing d ON p.id_dosen_pembimbing = d.id_dosen
                  LEFT JOIN user ud ON d.id_user = ud.id_user
                  LEFT JOIN guru_pembimbing g ON p.id_guru_pembimbing = g.id_guru
                  LEFT JOIN user ug ON g.id_user = ug.id_user
                  LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
                  WHERE b.id_bimbingan = ?";
        
        $stmt = $db->prepare($query);
        $stmt->execute([$id]);
        $bimbingan = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$bimbingan) {
            return errorResponse('Bimbingan tidak ditemukan', 404);
        }
        
        return successResponse($bimbingan, 'Detail bimbingan berhasil diambil');
    }
    
    /**
     * Get bimbingan by pengajuan ID
     * GET /bimbingan/pengajuan/{id_pengajuan}
     */
    public function getByPengajuan($idPengajuan) {
        $user = requireAuth();
        $db = getDB();
        
        $query = "SELECT * FROM bimbingan 
                  WHERE id_pengajuan = ? 
                  ORDER BY created_at DESC";
        $stmt = $db->prepare($query);
        $stmt->execute([$idPengajuan]);
        $bimbingan = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($bimbingan, 'Data bimbingan berhasil diambil');
    }
    
    /**
     * Create new bimbingan request
     * POST /bimbingan
     */
    public function create() {
        $user = requireAuth();
        
        // Only students can request bimbingan
        if (!in_array($user['role'], ['mahasiswa', 'siswa'])) {
            return errorResponse('Hanya mahasiswa/siswa yang dapat mengajukan bimbingan', 403);
        }
        
        $data = getJsonInput();
        
        // Validate required fields
        if (empty($data['id_pengajuan']) || empty($data['topik_bimbingan']) || empty($data['deskripsi_masalah'])) {
            return errorResponse('ID Pengajuan, topik, dan deskripsi masalah wajib diisi', 400);
        }
        
        $db = getDB();
        
        // Verify pengajuan exists and belongs to user
        $checkQuery = "SELECT p.*, 
                        CASE 
                            WHEN p.jenis_pengajuan = 'Magang' THEN m.id_user
                            ELSE s.id_user
                        END as id_user_pemilik,
                        CASE 
                            WHEN p.jenis_pengajuan = 'Magang' THEN d.id_user
                            ELSE g.id_user
                        END as id_user_pembimbing
                       FROM pengajuan p
                       LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                       LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                       LEFT JOIN dosen_pembimbing d ON p.id_dosen_pembimbing = d.id_dosen
                       LEFT JOIN guru_pembimbing g ON p.id_guru_pembimbing = g.id_guru
                       WHERE p.id_pengajuan = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$data['id_pengajuan']]);
        $pengajuan = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        if ($pengajuan['id_user_pemilik'] != $user['user_id']) {
            return errorResponse('Anda tidak memiliki akses ke pengajuan ini', 403);
        }
        
        // Insert bimbingan
        $query = "INSERT INTO bimbingan 
                  (id_pengajuan, topik_bimbingan, deskripsi_masalah, tanggal_pengajuan, catatan_mahasiswa)
                  VALUES (?, ?, ?, CURDATE(), ?)";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data['id_pengajuan'],
            $data['topik_bimbingan'],
            $data['deskripsi_masalah'],
            $data['catatan_mahasiswa'] ?? null
        ]);
        
        if ($result) {
            $newId = $db->lastInsertId();
            
            // Send notification to pembimbing
            if ($pengajuan['id_user_pembimbing']) {
                require_once __DIR__ . '/NotifikasiController.php';
                NotifikasiController::create(
                    $pengajuan['id_user_pembimbing'],
                    'Permintaan Bimbingan Baru',
                    'Ada permintaan bimbingan baru dengan topik: ' . $data['topik_bimbingan'],
                    'bimbingan'
                );
            }
            
            return successResponse(['id_bimbingan' => $newId], 'Permintaan bimbingan berhasil diajukan', 201);
        }
        
        return errorResponse('Gagal mengajukan bimbingan', 500);
    }
    
    /**
     * Schedule bimbingan (pembimbing only)
     * PUT /bimbingan/{id}/jadwal
     */
    public function setJadwal($id) {
        $user = requireAuth();
        
        if (!in_array($user['role'], ['dosen', 'guru', 'admin'])) {
            return errorResponse('Hanya pembimbing yang dapat menjadwalkan bimbingan', 403);
        }
        
        $data = getJsonInput();
        
        if (empty($data['tanggal_bimbingan'])) {
            return errorResponse('Tanggal bimbingan wajib diisi', 400);
        }
        
        $db = getDB();
        
        // Update bimbingan with schedule
        $query = "UPDATE bimbingan 
                  SET tanggal_bimbingan = ?, 
                      lokasi_bimbingan = ?,
                      status_bimbingan = 'Dijadwalkan'
                  WHERE id_bimbingan = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data['tanggal_bimbingan'],
            $data['lokasi_bimbingan'] ?? null,
            $id
        ]);
        
        if ($result && $stmt->rowCount() > 0) {
            // Get bimbingan to notify student
            $bimbingan = $this->getBimbinganWithUser($id);
            if ($bimbingan && $bimbingan['id_user_peserta']) {
                require_once __DIR__ . '/NotifikasiController.php';
                NotifikasiController::create(
                    $bimbingan['id_user_peserta'],
                    'Bimbingan Dijadwalkan',
                    'Permintaan bimbingan Anda telah dijadwalkan pada ' . $data['tanggal_bimbingan'],
                    'bimbingan'
                );
            }
            
            return successResponse(null, 'Jadwal bimbingan berhasil diatur');
        }
        
        return errorResponse('Gagal mengatur jadwal bimbingan', 500);
    }
    
    /**
     * Complete bimbingan with feedback (pembimbing only)
     * PUT /bimbingan/{id}/selesai
     */
    public function selesai($id) {
        $user = requireAuth();
        
        if (!in_array($user['role'], ['dosen', 'guru', 'admin'])) {
            return errorResponse('Hanya pembimbing yang dapat menyelesaikan bimbingan', 403);
        }
        
        $data = getJsonInput();
        
        $db = getDB();
        
        // Update bimbingan status to completed
        $query = "UPDATE bimbingan 
                  SET status_bimbingan = 'Selesai',
                      feedback_pembimbing = ?
                  WHERE id_bimbingan = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data['feedback_pembimbing'] ?? null,
            $id
        ]);
        
        if ($result && $stmt->rowCount() > 0) {
            // Notify student
            $bimbingan = $this->getBimbinganWithUser($id);
            if ($bimbingan && $bimbingan['id_user_peserta']) {
                require_once __DIR__ . '/NotifikasiController.php';
                NotifikasiController::create(
                    $bimbingan['id_user_peserta'],
                    'Bimbingan Selesai',
                    'Sesi bimbingan Anda telah selesai. Silakan berikan rating.',
                    'bimbingan'
                );
            }
            
            return successResponse(null, 'Bimbingan berhasil diselesaikan');
        }
        
        return errorResponse('Gagal menyelesaikan bimbingan', 500);
    }
    
    /**
     * Give rating (student only)
     * PUT /bimbingan/{id}/rating
     */
    public function giveRating($id) {
        $user = requireAuth();
        
        if (!in_array($user['role'], ['mahasiswa', 'siswa'])) {
            return errorResponse('Hanya mahasiswa/siswa yang dapat memberikan rating', 403);
        }
        
        $data = getJsonInput();
        
        if (empty($data['rating']) || $data['rating'] < 1 || $data['rating'] > 5) {
            return errorResponse('Rating harus antara 1-5', 400);
        }
        
        $db = getDB();
        
        // Update rating
        $query = "UPDATE bimbingan SET rating = ? WHERE id_bimbingan = ? AND status_bimbingan = 'Selesai'";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$data['rating'], $id]);
        
        if ($result && $stmt->rowCount() > 0) {
            return successResponse(null, 'Rating berhasil diberikan');
        }
        
        return errorResponse('Gagal memberikan rating. Pastikan bimbingan sudah selesai.', 500);
    }
    
    /**
     * Cancel bimbingan
     * PUT /bimbingan/{id}/batal
     */
    public function cancel($id) {
        $user = requireAuth();
        $db = getDB();
        
        // Get bimbingan to check ownership
        $bimbingan = $this->getBimbinganWithUser($id);
        if (!$bimbingan) {
            return errorResponse('Bimbingan tidak ditemukan', 404);
        }
        
        // Only owner or admin can cancel
        $canCancel = false;
        if ($user['role'] === 'admin') {
            $canCancel = true;
        } elseif (in_array($user['role'], ['mahasiswa', 'siswa']) && $bimbingan['id_user_peserta'] == $user['user_id']) {
            $canCancel = true;
        }
        
        if (!$canCancel) {
            return errorResponse('Anda tidak dapat membatalkan bimbingan ini', 403);
        }
        
        // Can only cancel if not completed
        if ($bimbingan['status_bimbingan'] === 'Selesai') {
            return errorResponse('Bimbingan yang sudah selesai tidak dapat dibatalkan', 400);
        }
        
        $query = "UPDATE bimbingan SET status_bimbingan = 'Dibatalkan' WHERE id_bimbingan = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$id]);
        
        if ($result) {
            return successResponse(null, 'Bimbingan berhasil dibatalkan');
        }
        
        return errorResponse('Gagal membatalkan bimbingan', 500);
    }
    
    /**
     * Helper: Get bimbingan with user info
     */
    private function getBimbinganWithUser($id) {
        $db = getDB();
        $query = "SELECT b.*, 
                    CASE 
                        WHEN p.jenis_pengajuan = 'Magang' THEN m.id_user
                        ELSE s.id_user
                    END as id_user_peserta
                  FROM bimbingan b
                  JOIN pengajuan p ON b.id_pengajuan = p.id_pengajuan
                  LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                  LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                  WHERE b.id_bimbingan = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
