<?php
/**
 * Users Controller (Admin Management)
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class UsersController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all users (Admin only)
     * Optional filter by role or status
     */
    public function getAll() {
        requireRole(['admin']);
        
        $role = $_GET['role'] ?? null;
        $status = $_GET['status'] ?? null;
        
        $sql = "SELECT id_user, username, nama_lengkap, email, role, is_active, created_at FROM user";
        $params = [];
        $conditions = [];
        
        if ($role) {
            $conditions[] = "role = ?";
            $params[] = $role;
        }
        
        if ($status !== null) {
            $conditions[] = "is_active = ?";
            $params[] = $status;
        }
        
        if (!empty($conditions)) {
            $sql .= " WHERE " . implode(' AND ', $conditions);
        }
        
        $sql .= " ORDER BY created_at DESC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        successResponse('Data users berhasil diambil', $users);
    }

    /**
     * Get user details by ID
     */
    public function getById($id) {
        requireRole(['admin']);
        
        $stmt = $this->db->prepare("SELECT id_user, username, nama_lengkap, email, role, is_active, created_at FROM user WHERE id_user = ?");
        $stmt->execute([$id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            errorResponse('User tidak ditemukan', null, 404);
        }
        
        // Fetch detail data based on role
        $detailFn = function($table, $key) use ($id) {
            $stmt = $this->db->prepare("SELECT * FROM $table WHERE id_user = ?");
            $stmt->execute([$id]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        };

        if ($user['role'] == 'mahasiswa') {
            $user['detail'] = $detailFn('mahasiswa', 'id_mahasiswa');
        } elseif ($user['role'] == 'dosen') {
            $user['detail'] = $detailFn('dosen_pembimbing', 'id_dosen');
        } elseif ($user['role'] == 'guru') {
            $user['detail'] = $detailFn('guru_pembimbing', 'id_guru');
        } elseif ($user['role'] == 'siswa') {
            $user['detail'] = $detailFn('siswa', 'id_siswa');
        } elseif ($user['role'] == 'instansi') {
            $user['detail'] = $detailFn('instansi', 'id_instansi');
        }

        successResponse('Detail user berhasil diambil', $user);
    }

    /**
     * Create user (Admin manual add)
     */
    /**
     * Create user (Admin manual add)
     */
    public function create() {
        requireRole(['admin']);
        $input = getJsonInput();
        
        // Basic validation
        if (empty($input['username']) || empty($input['password']) || empty($input['role'])) {
            errorResponse('Data user tidak lengkap (username, password, role)');
        }

        $role = $input['role'];
        $username = trim($input['username']);
        $email = isset($input['email']) ? trim($input['email']) : null;
        
        // Check availability of username/email
        $stmt = $this->db->prepare("SELECT COUNT(*) FROM user WHERE username = ? OR (email IS NOT NULL AND email != '' AND email = ?)");
        $stmt->execute([$username, $email]);
        if ($stmt->fetchColumn() > 0) {
            errorResponse('Username atau email sudah terdaftar');
        }

        // Validate Identifiers Uniqueness per Role to prevent duplicates before Insert
        if ($role === 'mahasiswa' && !empty($input['nim'])) {
            $this->checkUnique('mahasiswa', 'nim', $input['nim']);
        } elseif ($role === 'siswa' && !empty($input['nisn'])) {
            $this->checkUnique('siswa', 'nisn', $input['nisn']);
        } elseif ($role === 'dosen' && !empty($input['nidn'])) {
            $this->checkUnique('dosen_pembimbing', 'nidn', $input['nidn']);
        } elseif ($role === 'guru' && !empty($input['nip'])) {
            $this->checkUnique('guru_pembimbing', 'nip', $input['nip']);
        }

        $passwordHash = password_hash($input['password'], PASSWORD_DEFAULT);
        $status = $input['status_aktif'] ?? 1;

        try {
            $this->db->beginTransaction();

            // 1. Insert into User Table
            $stmt = $this->db->prepare("INSERT INTO user (username, password, email, nama_lengkap, role, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())");
            $stmt->execute([
                $username,
                $passwordHash,
                $email,
                $input['nama_lengkap'] ?? $username,
                $role,
                $status
            ]);
            
            $userId = $this->db->lastInsertId();

            // 2. Insert into Profile Table based on Role
            if ($role === 'mahasiswa') {
                $stmt = $this->db->prepare("INSERT INTO mahasiswa (id_user, nim, nama, prodi, fakultas, semester) VALUES (?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nim'] ?? null,
                    $input['nama_lengkap'],
                    $input['prodi'] ?? null,
                    $input['fakultas'] ?? null,
                    $input['semester'] ?? 1
                ]);
            } elseif ($role === 'siswa') {
                $stmt = $this->db->prepare("INSERT INTO siswa (id_user, nisn, nama_siswa, sekolah, jurusan, kelas) VALUES (?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nisn'] ?? null,
                    $input['nama_lengkap'],
                    $input['sekolah'] ?? null,
                    $input['jurusan'] ?? null,
                    $input['kelas'] ?? null
                ]);
            } elseif ($role === 'dosen') {
                $stmt = $this->db->prepare("INSERT INTO dosen_pembimbing (id_user, nidn, nama) VALUES (?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nidn'] ?? null,
                    $input['nama_lengkap']
                ]);
            } elseif ($role === 'guru') {
                $stmt = $this->db->prepare("INSERT INTO guru_pembimbing (id_user, nip, nama) VALUES (?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nip'] ?? null,
                    $input['nama_lengkap']
                ]);
            } elseif ($role === 'instansi') {
                $stmt = $this->db->prepare("INSERT INTO instansi (id_user, nama_instansi, alamat, kontak) VALUES (?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nama_lengkap'], // Nama Instansi taken from nama_lengkap
                    $input['alamat'] ?? null,
                    $input['kontak'] ?? null
                ]);
            } elseif ($role === 'admin_fakultas') {
                $stmt = $this->db->prepare("INSERT INTO admin_fakultas (id_user, nama, fakultas, jabatan) VALUES (?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nama_lengkap'],
                    $input['fakultas'] ?? null,
                    $input['jabatan'] ?? 'Admin'
                ]);
            } elseif ($role === 'admin_sekolah') {
                $stmt = $this->db->prepare("INSERT INTO admin_sekolah (id_user, nama, nama_sekolah, jabatan) VALUES (?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $input['nama_lengkap'],
                    $input['sekolah'] ?? null, // re-use sekolah field key
                    $input['jabatan'] ?? 'Admin'
                ]);
            }

            $this->db->commit();
            successResponse('User berhasil dibuat', ['id_user' => $userId]);

        } catch (Exception $e) {
            $this->db->rollBack();
            errorResponse('Gagal membuat user: ' . $e->getMessage());
        }
    }

    private function checkUnique($table, $column, $value) {
        $stmt = $this->db->prepare("SELECT COUNT(*) FROM $table WHERE $column = ?");
        $stmt->execute([$value]);
        if ($stmt->fetchColumn() > 0) {
            errorResponse("$column sudah terdaftar di sistem");
        }
    }

    /**
     * Update user (status or basic info)
     */
    public function update($id) {
        requireRole(['admin']);
        $input = getJsonInput();
        
        $updates = [];
        $params = [];
        
        if (isset($input['status_aktif'])) {
            $updates[] = "is_active = ?";
            $params[] = $input['status_aktif'];
        }
        
        if (isset($input['nama_lengkap'])) {
            $updates[] = "nama_lengkap = ?";
            $params[] = $input['nama_lengkap'];
        }
        
        if (isset($input['email'])) {
            // Check specific email unicity if changed
            $updates[] = "email = ?";
            $params[] = $input['email'];
        }

        if (isset($input['password']) && !empty($input['password'])) {
            $updates[] = "password = ?";
            $params[] = password_hash($input['password'], PASSWORD_DEFAULT);
        }

        if (empty($updates)) {
            errorResponse('Tidak ada data yang diupdate');
        }
        
        $params[] = $id;
        
        $sql = "UPDATE user SET " . implode(', ', $updates) . " WHERE id_user = ?";
        $stmt = $this->db->prepare($sql);
        
        if ($stmt->execute($params)) {
            successResponse('User berhasil diupdate');
        } else {
            errorResponse('Gagal mengupdate user');
        }
    }

    /**
     * Delete user
     */
    public function delete($id) {
        requireRole(['admin']);
        
        // Optional: Check if can be deleted (constraints)
        // Usually handled by DB FK ON DELETE CASCADE or restrict
        
        $stmt = $this->db->prepare("DELETE FROM user WHERE id_user = ?");
        if ($stmt->execute([$id])) {
            successResponse('User berhasil dihapus');
        } else {
            errorResponse('Gagal menghapus user');
        }
    }
}
