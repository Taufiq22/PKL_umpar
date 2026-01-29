<?php
/**
 * Auth Controller - Rewritten from Scratch
 * Supports both MD5 (legacy) and bcrypt password hashing
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class AuthController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Login - Supports all roles
     * Mahasiswa: login with NIM or username
     * Siswa: login with NISN or username
     * Dosen: login with NIDN or username
     * Guru: login with NIP or username
     * Instansi/Admin: login with username or email
     */
    public function login() {
        $input = getJsonInput();
        
        $identifier = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $role = trim($input['role'] ?? '');
        
        if (empty($identifier) || empty($password)) {
            errorResponse('Identitas dan password wajib diisi');
        }
        
        $user = null;
        
        // Role-based login
        if ($role === 'mahasiswa') {
            // Try NIM first, then username
            $user = $this->findMahasiswa($identifier);
        } elseif ($role === 'siswa') {
            // Try NISN first, then username
            $user = $this->findSiswa($identifier);
        } elseif ($role === 'dosen') {
            // Try NIDN first, then username
            $user = $this->findDosen($identifier);
        } elseif ($role === 'guru') {
            // Try NIP first, then username
            $user = $this->findGuru($identifier);
        } elseif ($role === 'instansi') {
            $user = $this->findByUsernameOrEmail($identifier, 'instansi');
        } elseif ($role === 'admin' || $role === 'admin_fakultas' || $role === 'admin_sekolah') {
            $user = $this->findByUsernameOrEmail($identifier, $role);
        } else {
            // Fallback: auto-detect by trying all
            $user = $this->autoDetectUser($identifier);
        }
        
        if (!$user) {
            errorResponse("Username/Identitas tidak ditemukan untuk role: $role");
        }
        
        // Verify password - support both bcrypt and MD5 (legacy)
        if (!$this->verifyPassword($password, $user['password'])) {
            errorResponse('Password salah');
        }
        
        if (!$user['is_active']) {
            errorResponse('Akun belum diaktivasi. Hubungi administrator.');
        }
        
        // Generate token
        $token = createToken($user['id_user'], $user['role']);
        
        // Remove password from response
        unset($user['password']);
        
        successResponse('Login berhasil', [
            'token' => $token,
            'user' => $user,
        ]);
    }

    /**
     * Find Mahasiswa by NIM or username
     */
    private function findMahasiswa($identifier) {
        // Try by NIM
        $stmt = $this->db->prepare("
            SELECT u.* FROM user u
            INNER JOIN mahasiswa m ON u.id_user = m.id_user
            WHERE m.nim = ? AND u.role = 'mahasiswa'
        ");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        
        if ($user) return $user;
        
        // Try by username
        $stmt = $this->db->prepare("SELECT * FROM user WHERE username = ? AND role = 'mahasiswa'");
        $stmt->execute([$identifier]);
        return $stmt->fetch();
    }

    /**
     * Find Siswa by NISN or username
     */
    private function findSiswa($identifier) {
        // Try by NISN
        $stmt = $this->db->prepare("
            SELECT u.* FROM user u
            INNER JOIN siswa s ON u.id_user = s.id_user
            WHERE s.nisn = ? AND u.role = 'siswa'
        ");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        
        if ($user) return $user;
        
        // Try by username
        $stmt = $this->db->prepare("SELECT * FROM user WHERE username = ? AND role = 'siswa'");
        $stmt->execute([$identifier]);
        return $stmt->fetch();
    }

    /**
     * Find Dosen by NIDN or username
     */
    private function findDosen($identifier) {
        // Try by NIDN
        $stmt = $this->db->prepare("
            SELECT u.* FROM user u
            INNER JOIN dosen_pembimbing d ON u.id_user = d.id_user
            WHERE d.nidn = ? AND u.role = 'dosen'
        ");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        
        if ($user) return $user;
        
        // Try by username
        $stmt = $this->db->prepare("SELECT * FROM user WHERE username = ? AND role = 'dosen'");
        $stmt->execute([$identifier]);
        return $stmt->fetch();
    }

    /**
     * Find Guru by NIP or username
     */
    private function findGuru($identifier) {
        // Try by NIP
        $stmt = $this->db->prepare("
            SELECT u.* FROM user u
            INNER JOIN guru_pembimbing g ON u.id_user = g.id_user
            WHERE g.nip = ? AND u.role = 'guru'
        ");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        
        if ($user) return $user;
        
        // Try by username
        $stmt = $this->db->prepare("SELECT * FROM user WHERE username = ? AND role = 'guru'");
        $stmt->execute([$identifier]);
        return $stmt->fetch();
    }

    /**
     * Find user by username or email
     */
    private function findByUsernameOrEmail($identifier, $role) {
        $stmt = $this->db->prepare("SELECT * FROM user WHERE (username = ? OR email = ?) AND role = ?");
        $stmt->execute([$identifier, $identifier, $role]);
        return $stmt->fetch();
    }

    /**
     * Auto-detect user from any identifier (fallback)
     */
    private function autoDetectUser($identifier) {
        // Try username first (any role)
        $stmt = $this->db->prepare("SELECT * FROM user WHERE username = ?");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        if ($user) return $user;
        
        // Try email
        $stmt = $this->db->prepare("SELECT * FROM user WHERE email = ?");
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
        if ($user) return $user;
        
        // Try NIM
        $user = $this->findMahasiswa($identifier);
        if ($user) return $user;
        
        // Try NISN
        $user = $this->findSiswa($identifier);
        if ($user) return $user;
        
        // Try NIDN
        $user = $this->findDosen($identifier);
        if ($user) return $user;
        
        // Try NIP
        return $this->findGuru($identifier);
    }

    /**
     * Verify password - supports both bcrypt and MD5 (legacy)
     */
    private function verifyPassword($inputPassword, $storedHash) {
        // Check if it's a bcrypt hash (starts with $2y$ or $2a$)
        if (strpos($storedHash, '$2y$') === 0 || strpos($storedHash, '$2a$') === 0) {
            return password_verify($inputPassword, $storedHash);
        }
        
        // Legacy MD5 hash (32 characters hexadecimal)
        if (strlen($storedHash) === 32 && ctype_xdigit($storedHash)) {
            return md5($inputPassword) === $storedHash;
        }
        
        // Fallback: try direct comparison (dangerous, but for debugging)
        return false;
    }

    /**
     * Register new user
     */
    public function register() {
        $input = getJsonInput();
        
        $namaLengkap = trim($input['nama_lengkap'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $role = trim($input['role'] ?? '');
        
        if (empty($namaLengkap) || empty($username) || empty($password) || empty($role)) {
            errorResponse('Semua field wajib diisi');
        }
        
        // Check valid roles for registration
        $validRoles = ['mahasiswa', 'siswa', 'dosen', 'guru', 'instansi'];
        if (!in_array($role, $validRoles)) {
            errorResponse('Role tidak valid untuk registrasi');
        }

        // Specific validation for Instansi
        if ($role === 'instansi') {
            if (empty($input['alamat']) || empty($input['kontak'])) {
                errorResponse('Alamat dan Kontak wajib diisi untuk Instansi');
            }
        }

        
        // Check username exists
        $stmt = $this->db->prepare("SELECT id_user FROM user WHERE username = ?");
        $stmt->execute([$username]);
        if ($stmt->fetch()) {
            errorResponse('Username sudah digunakan');
        }
        
        // Hash password with bcrypt
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
        
        try {
            $this->db->beginTransaction();
            
            // Insert user (inactive by default, admin needs to activate)
            $stmt = $this->db->prepare("
                INSERT INTO user (username, password, nama_lengkap, role, is_active, created_at) 
                VALUES (?, ?, ?, ?, 0, NOW())
            ");
            $stmt->execute([$username, $hashedPassword, $namaLengkap, $role]);
            $userId = $this->db->lastInsertId();
            
            // Insert role-specific data
            $this->insertRoleData($userId, $role, $input);
            
            $this->db->commit();
            successResponse('Registrasi berhasil. Silakan tunggu aktivasi dari admin.');
            
        } catch (Exception $e) {
            $this->db->rollBack();
            errorResponse('Registrasi gagal: ' . $e->getMessage(), null, 500);
        }
    }

    /**
     * Insert role-specific data
     */
    private function insertRoleData($userId, $role, $input) {
        if ($role === 'mahasiswa') {
            $nim = trim($input['nim'] ?? $input['username'] ?? '');
            $prodi = $input['prodi'] ?? '';
            $fakultas = $input['fakultas'] ?? '';
            $semester = $input['semester'] ?? 1;
            
            $stmt = $this->db->prepare("
                INSERT INTO mahasiswa (id_user, nim, prodi, fakultas, semester) 
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([$userId, $nim, $prodi, $fakultas, $semester]);
            
        } elseif ($role === 'siswa') {
            $nisn = trim($input['nisn'] ?? $input['username'] ?? '');
            $jurusan = $input['jurusan'] ?? '';
            $sekolah = $input['sekolah'] ?? '';
            $kelas = $input['kelas'] ?? '';
            
            $stmt = $this->db->prepare("
                INSERT INTO siswa (id_user, nisn, jurusan, sekolah, kelas) 
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([$userId, $nisn, $jurusan, $sekolah, $kelas]);
            
        } elseif ($role === 'dosen') {
            $nidn = trim($input['nidn'] ?? '');
            $stmt = $this->db->prepare("INSERT INTO dosen_pembimbing (id_user, nidn) VALUES (?, ?)");
            $stmt->execute([$userId, $nidn]);
            
        } elseif ($role === 'guru') {
            $nip = trim($input['nip'] ?? '');
            $stmt = $this->db->prepare("INSERT INTO guru_pembimbing (id_user, nip) VALUES (?, ?)");
            $stmt->execute([$userId, $nip]);
            
        } elseif ($role === 'instansi') {
            $alamat = $input['alamat'] ?? '-';
            $kontak = $input['kontak'] ?? '';
            $namaInstansi = $input['nama_lengkap'] ?? '';
            
            $stmt = $this->db->prepare("INSERT INTO instansi (id_user, nama_instansi, alamat, kontak) VALUES (?, ?, ?, ?)");
            $stmt->execute([$userId, $namaInstansi, $alamat, $kontak]);
        }
    }

    /**
     * Logout
     */
    public function logout() {
        successResponse('Logout berhasil');
    }

    /**
     * Get Profile
     */
    public function getProfil() {
        $authUser = requireAuth();
        
        $stmt = $this->db->prepare("SELECT * FROM user WHERE id_user = ?");
        $stmt->execute([$authUser['user_id']]);
        $user = $stmt->fetch();
        
        if (!$user) {
            errorResponse('User tidak ditemukan', null, 404);
        }
        
        unset($user['password']);
        
        // Get role-specific data
        $roleData = $this->getRoleData($user['id_user'], $user['role']);
        if ($roleData) {
            $user = array_merge($user, $roleData);
        }
        
        successResponse('Profil berhasil diambil', $user);
    }

    /**
     * Get role-specific data
     */
    private function getRoleData($userId, $role) {
        $table = null;
        switch ($role) {
            case 'mahasiswa':
                $table = 'mahasiswa';
                break;
            case 'siswa':
                $table = 'siswa';
                break;
            case 'dosen':
                $table = 'dosen_pembimbing';
                break;
            case 'guru':
                $table = 'guru_pembimbing';
                break;
            case 'instansi':
                $table = 'instansi';
                break;
            default:
                return null;
        }
        
        $stmt = $this->db->prepare("SELECT * FROM $table WHERE id_user = ?");
        $stmt->execute([$userId]);
        return $stmt->fetch();
    }

    /**
     * Update Profile
     */
    public function updateProfil() {
        $authUser = requireAuth();
        $input = getJsonInput();
        
        $db = $this->db;
        $role = $authUser['role'];
        $userId = $authUser['user_id'];

        try {
            $db->beginTransaction();

            // 1. Update Core User Data (users table)
            $userUpdates = [];
            $userParams = [];

            if (isset($input['nama_lengkap'])) {
                $userUpdates[] = "nama_lengkap = ?";
                $userParams[] = $input['nama_lengkap'];
            }
            if (isset($input['foto_profil'])) {
                $userUpdates[] = "foto_profil = ?";
                $userParams[] = $input['foto_profil'];
            }
            if (isset($input['email'])) {
                $userUpdates[] = "email = ?";
                $userParams[] = $input['email'];
            }

            if (!empty($userUpdates)) {
                $userParams[] = $userId;
                $sql = "UPDATE user SET " . implode(', ', $userUpdates) . " WHERE id_user = ?";
                $stmt = $db->prepare($sql);
                $stmt->execute($userParams);
            }

            // 2. Update Role Specific Data
            $roleUpdates = [];
            $roleParams = [];
            $table = '';
            $idColumn = 'id_user'; // Foreign key column

            if ($role === 'instansi') {
                $table = 'instansi';
                if (isset($input['alamat'])) {
                    $roleUpdates[] = "alamat = ?";
                    $roleParams[] = $input['alamat'];
                }
                if (isset($input['kontak'])) {
                    $roleUpdates[] = "kontak = ?";
                    $roleParams[] = $input['kontak'];
                }
                if (isset($input['nama_lengkap'])) { // sync nama_instansi with nama_lengkap
                    $roleUpdates[] = "nama_instansi = ?";
                    $roleParams[] = $input['nama_lengkap'];
                }
                if (isset($input['bidang'])) {
                    $roleUpdates[] = "bidang = ?";
                    $roleParams[] = $input['bidang'];
                }
            } elseif ($role === 'mahasiswa') {
                $table = 'mahasiswa';
                // Usually NIM, Prodi, Fakultas are locked or administrative, but assuming editable if requested
                // Let's allow editing phone/details if they existed, but table only has nim, prodi, fakultas, semester, ipk
                // We'll trust the input for now, but usually these are sync'd.
                if (isset($input['nim'])) {
                    $roleUpdates[] = "nim = ?";
                    $roleParams[] = $input['nim'];
                }
                if (isset($input['prodi'])) {
                    $roleUpdates[] = "prodi = ?";
                    $roleParams[] = $input['prodi'];
                }
                if (isset($input['fakultas'])) {
                    $roleUpdates[] = "fakultas = ?";
                    $roleParams[] = $input['fakultas'];
                }
            } elseif ($role === 'siswa') {
                $table = 'siswa';
                if (isset($input['nisn'])) {
                    $roleUpdates[] = "nisn = ?";
                    $roleParams[] = $input['nisn'];
                }
                if (isset($input['jurusan'])) {
                    $roleUpdates[] = "jurusan = ?";
                    $roleParams[] = $input['jurusan'];
                }
                if (isset($input['sekolah'])) {
                    $roleUpdates[] = "sekolah = ?";
                    $roleParams[] = $input['sekolah'];
                }
                if (isset($input['kelas'])) {
                    $roleUpdates[] = "kelas = ?";
                    $roleParams[] = $input['kelas'];
                }
            } elseif ($role === 'dosen') {
                $table = 'dosen_pembimbing';
                if (isset($input['nidn'])) {
                    $roleUpdates[] = "nidn = ?";
                    $roleParams[] = $input['nidn'];
                }
                if (isset($input['jabatan'])) {
                    $roleUpdates[] = "jabatan = ?";
                    $roleParams[] = $input['jabatan'];
                }
            } elseif ($role === 'guru') {
                $table = 'guru_pembimbing';
                if (isset($input['nip'])) {
                    $roleUpdates[] = "nip = ?";
                    $roleParams[] = $input['nip'];
                }
                if (isset($input['mata_pelajaran'])) {
                    $roleUpdates[] = "mata_pelajaran = ?";
                    $roleParams[] = $input['mata_pelajaran'];
                }
            }

            if (!empty($table) && !empty($roleUpdates)) {
                $roleParams[] = $userId;
                $sql = "UPDATE $table SET " . implode(', ', $roleUpdates) . " WHERE $idColumn = ?";
                $stmt = $db->prepare($sql);
                $stmt->execute($roleParams);
            }

            $db->commit();
            $this->getProfil();

        } catch (Exception $e) {
            $db->rollBack();
            errorResponse('Gagal update profil: ' . $e->getMessage());
        }
    }

    /**
     * Update Password
     */
    public function updatePassword() {
        $authUser = requireAuth();
        $input = getJsonInput();
        
        $passwordLama = $input['password_lama'] ?? null;
        $passwordBaru = $input['password_baru'] ?? null;
        
        if (empty($passwordLama) || empty($passwordBaru)) {
            errorResponse('Password lama dan password baru wajib diisi');
        }
        
        if (strlen($passwordBaru) < 6) {
            errorResponse('Password baru minimal 6 karakter');
        }
        
        // Verify old password
        $stmt = $this->db->prepare("SELECT password FROM user WHERE id_user = ?");
        $stmt->execute([$authUser['user_id']]);
        $user = $stmt->fetch();
        
        if (!$user || !$this->verifyPassword($passwordLama, $user['password'])) {
            errorResponse('Password lama tidak sesuai');
        }
        
        // Update to bcrypt
        $newPasswordHash = password_hash($passwordBaru, PASSWORD_BCRYPT);
        $stmt = $this->db->prepare("UPDATE user SET password = ? WHERE id_user = ?");
        $stmt->execute([$newPasswordHash, $authUser['user_id']]);
        
        successResponse('Password berhasil diubah');
    }
}
