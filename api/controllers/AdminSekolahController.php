<?php
/**
 * AdminSekolahController - School Admin Management
 * UMPAR Magang & PKL System
 * 
 * Handles school-level administration for PKL applications
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class AdminSekolahController {
    
    /**
     * Get admin sekolah profile
     * GET /admin-sekolah/profil
     */
    public function getProfil() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_sekolah') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        $query = "SELECT asek.*, u.username, u.email as user_email
                  FROM admin_sekolah asek
                  JOIN user u ON asek.id_user = u.id_user
                  WHERE asek.id_user = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$user['id_user']]);
        $profil = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$profil) {
            return errorResponse('Profil tidak ditemukan', 404);
        }
        
        return successResponse($profil, 'Profil berhasil diambil');
    }
    
    /**
     * Get pengajuan by sekolah
     * GET /admin-sekolah/pengajuan
     */
    public function getPengajuanBySekolah() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's sekolah
        $adminQuery = "SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?";
        $stmt = $db->prepare($adminQuery);
        $stmt->execute([$user['id_user']]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$admin && $user['role'] !== 'admin') {
            return errorResponse('Data admin tidak ditemukan', 404);
        }
        
        // Get pengajuan for siswa in this sekolah
        $query = "SELECT p.*, s.nama as nama_siswa, s.nisn, s.nama_sekolah, s.kelas,
                    g.nama as nama_guru, i.nama_instansi,
                    p.status_pengajuan
                  FROM pengajuan p
                  JOIN siswa s ON p.id_siswa = s.id_siswa
                  LEFT JOIN guru_pembimbing g ON p.id_guru_pembimbing = g.id_guru_pembimbing
                  LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
                  WHERE p.jenis_pengajuan = 'PKL'";
        
        $params = [];
        
        // Filter by sekolah if admin_sekolah
        if ($user['role'] === 'admin_sekolah' && $admin) {
            $query .= " AND s.nama_sekolah = ?";
            $params[] = $admin['nama_sekolah'];
        }
        
        // Filter by status if provided
        if (isset($_GET['status']) && !empty($_GET['status'])) {
            $query .= " AND p.status_pengajuan = ?";
            $params[] = $_GET['status'];
        }
        
        $query .= " ORDER BY p.created_at DESC";
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $pengajuan = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($pengajuan, 'Data pengajuan berhasil diambil');
    }
    
    /**
     * Get statistics for sekolah
     * GET /admin-sekolah/statistik
     */
    public function getStatistik() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's sekolah
        $namaSekolah = null;
        if ($user['role'] === 'admin_sekolah') {
            $adminQuery = "SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?";
            $stmt = $db->prepare($adminQuery);
            $stmt->execute([$user['id_user']]);
            $admin = $stmt->fetch(PDO::FETCH_ASSOC);
            $namaSekolah = $admin['nama_sekolah'] ?? null;
        }
        
        // Build statistics query
        $baseWhere = "p.jenis_pengajuan = 'PKL'";
        $params = [];
        
        if ($namaSekolah) {
            $baseWhere .= " AND s.nama_sekolah = ?";
            $params[] = $namaSekolah;
        }
        
        // Total pengajuan
        $totalQuery = "SELECT COUNT(*) as total FROM pengajuan p
                       JOIN siswa s ON p.id_siswa = s.id_siswa
                       WHERE $baseWhere";
        $stmt = $db->prepare($totalQuery);
        $stmt->execute($params);
        $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // By status
        $statusQuery = "SELECT p.status_pengajuan, COUNT(*) as jumlah 
                        FROM pengajuan p
                        JOIN siswa s ON p.id_siswa = s.id_siswa
                        WHERE $baseWhere
                        GROUP BY p.status_pengajuan";
        $stmt = $db->prepare($statusQuery);
        $stmt->execute($params);
        $byStatus = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // By kelas
        $kelasQuery = "SELECT s.kelas, COUNT(*) as jumlah 
                       FROM pengajuan p
                       JOIN siswa s ON p.id_siswa = s.id_siswa
                       WHERE $baseWhere
                       GROUP BY s.kelas";
        $stmt = $db->prepare($kelasQuery);
        $stmt->execute($params);
        $byKelas = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse([
            'total_pengajuan' => $total,
            'by_status' => $byStatus,
            'by_kelas' => $byKelas,
            'nama_sekolah' => $namaSekolah
        ], 'Statistik berhasil diambil');
    }
    
    /**
     * Get list of siswa in sekolah
     * GET /admin-sekolah/siswa
     */
    public function getSiswa() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's sekolah
        $namaSekolah = null;
        if ($user['role'] === 'admin_sekolah') {
            $adminQuery = "SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?";
            $stmt = $db->prepare($adminQuery);
            $stmt->execute([$user['id_user']]);
            $admin = $stmt->fetch(PDO::FETCH_ASSOC);
            $namaSekolah = $admin['nama_sekolah'] ?? null;
        }
        
        $query = "SELECT s.*, 
                    (SELECT COUNT(*) FROM pengajuan p WHERE p.id_siswa = s.id_siswa) as total_pengajuan,
                    (SELECT status_pengajuan FROM pengajuan p WHERE p.id_siswa = s.id_siswa ORDER BY p.created_at DESC LIMIT 1) as status_terakhir
                  FROM siswa s";
        $params = [];
        
        if ($namaSekolah) {
            $query .= " WHERE s.nama_sekolah = ?";
            $params[] = $namaSekolah;
        }
        
        $query .= " ORDER BY s.nama ASC";
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $siswa = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($siswa, 'Data siswa berhasil diambil');
    }
    
    /**
     * Get list of guru pembimbing in sekolah
     * GET /admin-sekolah/guru
     */
    public function getGuruPembimbing() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        $query = "SELECT g.*,
                    (SELECT COUNT(*) FROM pengajuan p WHERE p.id_guru_pembimbing = g.id_guru_pembimbing) as total_bimbingan
                  FROM guru_pembimbing g
                  ORDER BY g.nama ASC";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        $guru = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($guru, 'Data guru pembimbing berhasil diambil');
    }

    /**
     * Create new Guru Pembimbing
     * POST /admin-sekolah/guru
     */
    public function createGuru() {
        $user = requireAuth();
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }

        $input = getJsonInput();
        if (empty($input['username']) || empty($input['password']) || empty($input['nama_lengkap'])) {
            return errorResponse('Data tidak lengkap');
        }

        $db = getDB();

        // Check availability
        $stmt = $db->prepare("SELECT COUNT(*) FROM user WHERE username = ?");
        $stmt->execute([$input['username']]);
        if ($stmt->fetchColumn() > 0) {
            return errorResponse('Username sudah terdaftar');
        }

        // Check NIP uniqueness
        if (!empty($input['nip'])) {
            $stmt = $db->prepare("SELECT COUNT(*) FROM guru_pembimbing WHERE nip = ?");
            $stmt->execute([$input['nip']]);
            if ($stmt->fetchColumn() > 0) {
                return errorResponse('NIP sudah terdaftar');
            }
        }

        try {
            $db->beginTransaction();

            // Create User
            $passwordHash = password_hash($input['password'], PASSWORD_DEFAULT);
            $stmt = $db->prepare("INSERT INTO user (username, password, email, nama_lengkap, role, is_active, created_at) VALUES (?, ?, ?, ?, 'guru', 1, NOW())");
            $stmt->execute([
                $input['username'],
                $passwordHash,
                $input['email'] ?? null,
                $input['nama_lengkap']
            ]);
            $userId = $db->lastInsertId();

            // Create Guru Profile
            $stmt = $db->prepare("INSERT INTO guru_pembimbing (id_user, nip, nama, mata_pelajaran) VALUES (?, ?, ?, ?)");
            $stmt->execute([
                $userId,
                $input['nip'] ?? null,
                $input['nama_lengkap'],
                $input['mata_pelajaran'] ?? null
            ]);

            $db->commit();
            successResponse('Guru berhasil ditambahkan', ['id_user' => $userId]);

        } catch (Exception $e) {
            $db->rollBack();
            errorResponse('Gagal menambah guru: ' . $e->getMessage());
        }
    }

    /**
     * Delete Guru Pembimbing
     * DELETE /admin-sekolah/guru/{id}
     */
    public function deleteGuru($id) {
        $user = requireAuth();
        if ($user['role'] !== 'admin_sekolah' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }

        $db = getDB();

        // Verify target is actually a guru
        $stmt = $db->prepare("SELECT role FROM user WHERE id_user = ?");
        $stmt->execute([$id]);
        $target = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$target || $target['role'] !== 'guru') {
            return errorResponse('User bukan guru atau tidak ditemukan');
        }

        try {
            // Delete user (Cascade should handle profile)
            $stmt = $db->prepare("DELETE FROM user WHERE id_user = ?");
            $stmt->execute([$id]);
            
            successResponse('Guru berhasil dihapus');
        } catch (Exception $e) {
            errorResponse('Gagal menghapus guru: ' . $e->getMessage());
        }
    }
}
