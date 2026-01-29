<?php
/**
 * AdminFakultasController - Faculty Admin Management
 * UMPAR Magang & PKL System
 * 
 * Handles faculty-level administration for magang applications
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class AdminFakultasController {
    
    /**
     * Get admin fakultas profile
     * GET /admin-fakultas/profil
     */
    public function getProfil() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_fakultas') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        $query = "SELECT af.*, u.username, u.email as user_email
                  FROM admin_fakultas af
                  JOIN user u ON af.id_user = u.id_user
                  WHERE af.id_user = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$user['id_user']]);
        $profil = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$profil) {
            return errorResponse('Profil tidak ditemukan', 404);
        }
        
        return successResponse($profil, 'Profil berhasil diambil');
    }
    
    /**
     * Get pengajuan by fakultas
     * GET /admin-fakultas/pengajuan
     */
    public function getPengajuanByFakultas() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's fakultas
        $adminQuery = "SELECT fakultas FROM admin_fakultas WHERE id_user = ?";
        $stmt = $db->prepare($adminQuery);
        $stmt->execute([$user['id_user']]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$admin && $user['role'] !== 'admin') {
            return errorResponse('Data admin tidak ditemukan', 404);
        }
        
        // Get pengajuan for mahasiswa in this fakultas
        $query = "SELECT p.*, m.nama as nama_mahasiswa, m.nim, m.fakultas, m.prodi,
                    d.nama as nama_dosen, i.nama_instansi,
                    p.status_pengajuan
                  FROM pengajuan p
                  JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                  LEFT JOIN dosen_pembimbing d ON p.id_dosen_pembimbing = d.id_dosen_pembimbing
                  LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
                  WHERE p.jenis_pengajuan = 'Magang'";
        
        $params = [];
        
        // Filter by fakultas if admin_fakultas
        if ($user['role'] === 'admin_fakultas' && $admin) {
            $query .= " AND m.fakultas = ?";
            $params[] = $admin['fakultas'];
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
     * Get statistics for fakultas
     * GET /admin-fakultas/statistik
     */
    public function getStatistik() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's fakultas
        $fakultas = null;
        if ($user['role'] === 'admin_fakultas') {
            $adminQuery = "SELECT fakultas FROM admin_fakultas WHERE id_user = ?";
            $stmt = $db->prepare($adminQuery);
            $stmt->execute([$user['id_user']]);
            $admin = $stmt->fetch(PDO::FETCH_ASSOC);
            $fakultas = $admin['fakultas'] ?? null;
        }
        
        // Build statistics query
        $baseWhere = "p.jenis_pengajuan = 'Magang'";
        $params = [];
        
        if ($fakultas) {
            $baseWhere .= " AND m.fakultas = ?";
            $params[] = $fakultas;
        }
        
        // Total pengajuan
        $totalQuery = "SELECT COUNT(*) as total FROM pengajuan p
                       JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                       WHERE $baseWhere";
        $stmt = $db->prepare($totalQuery);
        $stmt->execute($params);
        $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // By status
        $statusQuery = "SELECT p.status_pengajuan, COUNT(*) as jumlah 
                        FROM pengajuan p
                        JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                        WHERE $baseWhere
                        GROUP BY p.status_pengajuan";
        $stmt = $db->prepare($statusQuery);
        $stmt->execute($params);
        $byStatus = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // By prodi
        $prodiQuery = "SELECT m.prodi, COUNT(*) as jumlah 
                       FROM pengajuan p
                       JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                       WHERE $baseWhere
                       GROUP BY m.prodi";
        $stmt = $db->prepare($prodiQuery);
        $stmt->execute($params);
        $byProdi = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse([
            'total_pengajuan' => $total,
            'by_status' => $byStatus,
            'by_prodi' => $byProdi,
            'fakultas' => $fakultas
        ], 'Statistik berhasil diambil');
    }
    
    /**
     * Get list of mahasiswa in fakultas
     * GET /admin-fakultas/mahasiswa
     */
    public function getMahasiswa() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        // Get admin's fakultas
        $fakultas = null;
        if ($user['role'] === 'admin_fakultas') {
            $adminQuery = "SELECT fakultas FROM admin_fakultas WHERE id_user = ?";
            $stmt = $db->prepare($adminQuery);
            $stmt->execute([$user['id_user']]);
            $admin = $stmt->fetch(PDO::FETCH_ASSOC);
            $fakultas = $admin['fakultas'] ?? null;
        }
        
        $query = "SELECT m.*, 
                    (SELECT COUNT(*) FROM pengajuan p WHERE p.id_mahasiswa = m.id_mahasiswa) as total_pengajuan,
                    (SELECT status_pengajuan FROM pengajuan p WHERE p.id_mahasiswa = m.id_mahasiswa ORDER BY p.created_at DESC LIMIT 1) as status_terakhir
                  FROM mahasiswa m";
        $params = [];
        
        if ($fakultas) {
            $query .= " WHERE m.fakultas = ?";
            $params[] = $fakultas;
        }
        
        $query .= " ORDER BY m.nama ASC";
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $mahasiswa = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($mahasiswa, 'Data mahasiswa berhasil diambil');
    }
    
    /**
     * Get list of dosen pembimbing in fakultas
     * GET /admin-fakultas/dosen
     */
    public function getDosenPembimbing() {
        $user = requireAuth();
        
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }
        
        $db = getDB();
        
        $query = "SELECT d.*,
                    (SELECT COUNT(*) FROM pengajuan p WHERE p.id_dosen_pembimbing = d.id_dosen_pembimbing) as total_bimbingan
                  FROM dosen_pembimbing d
                  ORDER BY d.nama ASC";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        $dosen = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($dosen, 'Data dosen pembimbing berhasil diambil');
    }
    /**
     * Create Dosen Pembimbing (Admin Fakultas specific)
     * POST /admin-fakultas/dosen
     */
    public function createDosen() {
        $user = requireAuth();
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }

        $input = getJsonInput();
        if (empty($input['username']) || empty($input['password']) || empty($input['nama_lengkap'])) {
            errorResponse('Data tidak lengkap');
        }

        $db = getDB();

        // Check availability
        $stmt = $db->prepare("SELECT COUNT(*) FROM user WHERE username = ?");
        $stmt->execute([$input['username']]);
        if ($stmt->fetchColumn() > 0) {
            errorResponse('Username sudah terdaftar');
        }

        // Check NIDN uniqueness
        if (!empty($input['nidn'])) {
            $stmt = $db->prepare("SELECT COUNT(*) FROM dosen_pembimbing WHERE nidn = ?");
            $stmt->execute([$input['nidn']]);
            if ($stmt->fetchColumn() > 0) {
                errorResponse('NIDN sudah terdaftar');
            }
        }

        try {
            $db->beginTransaction();

            // Create User
            $passwordHash = password_hash($input['password'], PASSWORD_DEFAULT);
            $stmt = $db->prepare("INSERT INTO user (username, password, email, nama_lengkap, role, is_active, created_at) VALUES (?, ?, ?, ?, 'dosen', 1, NOW())");
            $stmt->execute([
                $input['username'],
                $passwordHash,
                $input['email'] ?? null,
                $input['nama_lengkap']
            ]);
            $userId = $db->lastInsertId();

            // Create Dosen Profile
            $stmt = $db->prepare("INSERT INTO dosen_pembimbing (id_user, nidn, nama) VALUES (?, ?, ?)");
            $stmt->execute([
                $userId,
                $input['nidn'] ?? null,
                $input['nama_lengkap']
            ]);

            $db->commit();
            successResponse('Dosen berhasil ditambahkan', ['id_user' => $userId]);

        } catch (Exception $e) {
            $db->rollBack();
            errorResponse('Gagal menambah dosen: ' . $e->getMessage());
        }
    }

    /**
     * Delete Dosen (Admin Fakultas specific)
     * DELETE /admin-fakultas/dosen/:id
     */
    public function deleteDosen($id) {
        $user = requireAuth();
        if ($user['role'] !== 'admin_fakultas' && $user['role'] !== 'admin') {
            return errorResponse('Akses ditolak', 403);
        }

        $db = getDB();

        // Verify target is actually a dosen
        $stmt = $db->prepare("SELECT role FROM user WHERE id_user = ?");
        $stmt->execute([$id]);
        $target = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$target || $target['role'] !== 'dosen') {
            return errorResponse('User bukan dosen atau tidak ditemukan');
        }

        try {
            // Delete user (Cascade should handle profile, but we can be explicit if needed)
            // Assuming ON DELETE CASCADE in DB for foreign keys
            $stmt = $db->prepare("DELETE FROM user WHERE id_user = ?");
            $stmt->execute([$id]);
            
            successResponse('Dosen berhasil dihapus');
        } catch (Exception $e) {
            errorResponse('Gagal menghapus dosen: ' . $e->getMessage());
        }
    }
}
