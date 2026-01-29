<?php
/**
 * Pengajuan Controller
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/NotifikasiController.php';
require_once __DIR__ . '/CetakController.php';

class PengajuanController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all pengajuan (filtered by role)
     */
    public function getAll() {
        $authUser = requireAuth();
        
        $sql = "SELECT p.*, i.nama_instansi, 
                       u_mhs.nama_lengkap as nama_mahasiswa,
                       u_siswa.nama_lengkap as nama_siswa
                FROM pengajuan p 
                LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
                LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                LEFT JOIN user u_mhs ON m.id_user = u_mhs.id_user
                LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                LEFT JOIN user u_siswa ON s.id_user = u_siswa.id_user";
        $params = [];
        
        switch ($authUser['role']) {
            case 'mahasiswa':
                $stmt = $this->db->prepare("SELECT id_mahasiswa FROM mahasiswa WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $mhs = $stmt->fetch();
                $sql .= " WHERE p.id_mahasiswa = ?";
                $params[] = $mhs['id_mahasiswa'] ?? 0;
                break;
            case 'siswa':
                $stmt = $this->db->prepare("SELECT id_siswa FROM siswa WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $siswa = $stmt->fetch();
                $sql .= " WHERE p.id_siswa = ?";
                $params[] = $siswa['id_siswa'] ?? 0;
                break;
            case 'dosen':
                // Dosen: Lihat pengajuan magang yang di-assign ATAU yang status 'Diajukan' (untuk verifikasi)
                $stmt = $this->db->prepare("SELECT id_dosen FROM dosen_pembimbing WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $dosen = $stmt->fetch();
                $dosenId = $dosen['id_dosen'] ?? 0;
                $sql .= " WHERE (p.id_dosen_pembimbing = ? OR (p.jenis_pengajuan = 'Magang' AND p.status_pengajuan = 'Diajukan'))";
                $params[] = $dosenId;
                break;
            case 'guru':
                // Guru: Lihat pengajuan PKL yang di-assign ATAU yang status 'Diajukan' (untuk verifikasi)
                $stmt = $this->db->prepare("SELECT id_guru FROM guru_pembimbing WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $guru = $stmt->fetch();
                $guruId = $guru['id_guru'] ?? 0;
                $sql .= " WHERE (p.id_guru_pembimbing = ? OR (p.jenis_pengajuan = 'PKL' AND p.status_pengajuan = 'Diajukan'))";
                $params[] = $guruId;
                break;
            case 'instansi':
                $stmt = $this->db->prepare("SELECT id_instansi FROM instansi WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $inst = $stmt->fetch();
                $sql .= " WHERE p.id_instansi = ?";
                $params[] = $inst['id_instansi'] ?? 0;
                break;
            case 'admin_fakultas':
                // Admin Fakultas: Lihat pengajuan Magang dari fakultasnya
                $stmt = $this->db->prepare("SELECT fakultas FROM admin_fakultas WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $adm = $stmt->fetch();
                $fakultas = $adm['fakultas'] ?? '';
                
                // Filter join logic needed to be adjusted in main query, but simplest way is to add condition on m.fakultas
                // Since main query already joins mahasiswa m, we can just use m.fakultas
                $sql .= " WHERE p.jenis_pengajuan = 'Magang' AND m.fakultas = ?";
                $params[] = $fakultas;
                break;
            case 'admin_sekolah':
                // Admin Sekolah: Lihat pengajuan PKL dari sekolahnya
                $stmt = $this->db->prepare("SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?");
                $stmt->execute([$authUser['user_id']]);
                $adm = $stmt->fetch();
                $sekolah = $adm['nama_sekolah'] ?? '';
                
                // Since main query already joins siswa s, we can use s.nama_sekolah
                $sql .= " WHERE p.jenis_pengajuan = 'PKL' AND s.nama_sekolah = ?";
                $params[] = $sekolah;
                break;
            case 'admin':
                // Admin sees all
                break;
        }
        
        $sql .= " ORDER BY p.created_at DESC";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        
        successResponse('Data pengajuan berhasil diambil', $stmt->fetchAll());
    }

    /**
     * Get pengajuan by ID
     */
    public function getById($id) {
        $authUser = requireAuth();
        
        $stmt = $this->db->prepare("
            SELECT p.*, i.nama_instansi, i.alamat as alamat_instansi,
                   u_mhs.nama_lengkap as nama_mahasiswa,
                   u_siswa.nama_lengkap as nama_siswa
            FROM pengajuan p 
            LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
            LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
            LEFT JOIN user u_mhs ON m.id_user = u_mhs.id_user
            LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
            LEFT JOIN user u_siswa ON s.id_user = u_siswa.id_user
            WHERE p.id_pengajuan = ?
        ");
        $stmt->execute([$id]);
        $data = $stmt->fetch();
        
        if (!$data) {
            errorResponse('Pengajuan tidak ditemukan', null, 404);
        }
        
        successResponse('Data pengajuan berhasil diambil', $data);
    }

    /**
     * Create new pengajuan
     */
    public function create() {
        $authUser = requireAuth();
        $input = getJsonInput();
        
        $jenisPengajuan = $input['jenis_pengajuan'] ?? 'Magang';
        $idInstansi = $input['id_instansi'] ?? null;
        $posisi = $input['posisi'] ?? null;
        $tanggalMulai = $input['tanggal_mulai'] ?? null;
        $tanggalSelesai = $input['tanggal_selesai'] ?? null;
        $durasiBulan = $input['durasi_bulan'] ?? 1;
        $keterangan = $input['keterangan'] ?? null;
        
        $idMahasiswa = null;
        $idSiswa = null;
        
        if ($authUser['role'] === 'mahasiswa') {
            $stmt = $this->db->prepare("SELECT id_mahasiswa FROM mahasiswa WHERE id_user = ?");
            $stmt->execute([$authUser['user_id']]);
            $mhs = $stmt->fetch();
            $idMahasiswa = $mhs['id_mahasiswa'] ?? null;
        } elseif ($authUser['role'] === 'siswa') {
            $stmt = $this->db->prepare("SELECT id_siswa FROM siswa WHERE id_user = ?");
            $stmt->execute([$authUser['user_id']]);
            $siswa = $stmt->fetch();
            $idSiswa = $siswa['id_siswa'] ?? null;
        }
        
        $stmt = $this->db->prepare("
            INSERT INTO pengajuan (id_mahasiswa, id_siswa, jenis_pengajuan, id_instansi, posisi, tanggal_mulai, tanggal_selesai, durasi_bulan, keterangan, status_pengajuan, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Diajukan', NOW())
        ");
        $stmt->execute([$idMahasiswa, $idSiswa, $jenisPengajuan, $idInstansi, $posisi, $tanggalMulai, $tanggalSelesai, $durasiBulan, $keterangan]);
        $idPengajuan = $this->db->lastInsertId();
        
        // Auto-notification: Notify all dosen/guru for verification
        $pembimbingRole = $jenisPengajuan === 'Magang' ? 'dosen' : 'guru';
        $stmtPembimbing = $this->db->prepare("SELECT id_user FROM user WHERE role = ?");
        $stmtPembimbing->execute([$pembimbingRole]);
        $pembimbings = $stmtPembimbing->fetchAll();
        foreach ($pembimbings as $p) {
            NotifikasiController::create(
                $p['id_user'],
                'Pengajuan Baru',
                "Ada pengajuan $jenisPengajuan baru yang perlu diverifikasi",
                'info'
            );
        }
        
        successResponse('Pengajuan berhasil dibuat', ['id_pengajuan' => $idPengajuan]);
    }

    /**
     * Update pengajuan
     */
    public function update($id) {
        requireAuth();
        $input = getJsonInput();
        
        $updates = [];
        $params = [];
        
        $allowedFields = ['posisi', 'tanggal_mulai', 'tanggal_selesai', 'durasi_bulan', 'keterangan', 'id_instansi'];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $params[] = $input[$field];
            }
        }
        
        if (empty($updates)) {
            errorResponse('Tidak ada data yang diupdate');
        }
        
        $params[] = $id;
        
        $sql = "UPDATE pengajuan SET " . implode(', ', $updates) . " WHERE id_pengajuan = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        
        successResponse('Pengajuan berhasil diupdate');
    }

    /**
     * Verifikasi pengajuan (for dosen/guru)
     */
    public function verifikasi($id) {
        $authUser = requireRole(['dosen', 'guru', 'admin']);
        $input = getJsonInput();
        
        $disetujui = $input['disetujui'] ?? false;
        $catatan = $input['catatan'] ?? null;
        $idPembimbing = $input['id_pembimbing'] ?? null;
        $tipePembimbing = $input['tipe_pembimbing'] ?? null;
        
        $status = $disetujui ? 'Disetujui' : 'Ditolak';
        
        // Build update query
        $updates = ['status_pengajuan = ?'];
        $params = [$status];
        
        // If approved and pembimbing is assigned
        if ($disetujui && $idPembimbing !== null && $tipePembimbing !== null) {
            if ($tipePembimbing === 'dosen') {
                $updates[] = 'id_dosen_pembimbing = ?';
            } else {
                $updates[] = 'id_guru_pembimbing = ?';
            }
            $params[] = $idPembimbing;
        }
        
        $params[] = $id;
        
        $sql = "UPDATE pengajuan SET " . implode(', ', $updates) . " WHERE id_pengajuan = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        
        // Auto-notification: Notify mahasiswa/siswa about verification result
        $stmtPengajuan = $this->db->prepare("
            SELECT p.*, m.id_user as id_user_mhs, s.id_user as id_user_siswa 
            FROM pengajuan p
            LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
            LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
            WHERE p.id_pengajuan = ?
        ");
        $stmtPengajuan->execute([$id]);
        $pengajuan = $stmtPengajuan->fetch();
        
        $idUserTarget = $pengajuan['id_user_mhs'] ?? $pengajuan['id_user_siswa'];
        if ($idUserTarget) {
            $tipe = $disetujui ? 'success' : 'warning';
            $pesan = $disetujui 
                ? 'Pengajuan Anda telah disetujui. Silakan mulai kegiatan sesuai jadwal.'
                : 'Pengajuan Anda ditolak. ' . ($catatan ? "Catatan: $catatan" : '');
            NotifikasiController::create($idUserTarget, "Pengajuan $status", $pesan, $tipe);
        }
        
        successResponse("Pengajuan berhasil $status");
    }
    
    /**
     * Approval by Admin Fakultas (for Magang applications)
     * PUT /pengajuan/{id}/approve-fakultas
     */
    public function approveByFakultas($id) {
        $authUser = requireRole(['admin_fakultas', 'admin']);
        $input = getJsonInput();
        
        $approved = $input['approved'] ?? false;
        $catatan = $input['catatan'] ?? null;
        
        // Verify this is a Magang application
        $stmt = $this->db->prepare("SELECT * FROM pengajuan WHERE id_pengajuan = ?");
        $stmt->execute([$id]);
        $pengajuan = $stmt->fetch();
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        if ($pengajuan['jenis_pengajuan'] !== 'Magang') {
            return errorResponse('Hanya pengajuan Magang yang dapat disetujui oleh Admin Fakultas', 400);
        }
        
        // Update approval status
        $idPembimbing = $input['id_pembimbing'] ?? null;
        
        // Update approval status and assign pembimbing if approved
        $status = $approved ? 'approved' : 'rejected';
        
        $query = "UPDATE pengajuan SET 
                    status_admin_fakultas = ?,
                    approved_by_fakultas = ?,
                    approved_at_fakultas = NOW(),
                    catatan_fakultas = ?";
        
        $params = [$status, $authUser['id_user'], $catatan];

        if ($approved && $idPembimbing) {
            $query .= ", id_dosen_pembimbing = ?";
            $params[] = $idPembimbing;
        }

        $query .= " WHERE id_pengajuan = ?";
        $params[] = $id;
        
        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        
        // If approved, also update main status and generate document
        if ($approved) {
            $this->db->prepare("UPDATE pengajuan SET status_pengajuan = 'Disetujui' WHERE id_pengajuan = ?")
                     ->execute([$id]);
            
            // Auto-generate document
            CetakController::generateOnApproval($id);
        } elseif (!$approved) {
            $this->db->prepare("UPDATE pengajuan SET status_pengajuan = 'Ditolak' WHERE id_pengajuan = ?")
                     ->execute([$id]);
        }
        
        // Send notification to mahasiswa
        $stmtUser = $this->db->prepare("
            SELECT m.id_user FROM pengajuan p
            JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
            WHERE p.id_pengajuan = ?
        ");
        $stmtUser->execute([$id]);
        $userData = $stmtUser->fetch();
        
        if ($userData) {
            $tipe = $approved ? 'success' : 'warning';
            $pesan = $approved 
                ? 'Pengajuan Magang Anda telah disetujui oleh Admin Fakultas. Surat permohonan telah digenerate.'
                : 'Pengajuan Magang Anda ditolak oleh Admin Fakultas. ' . ($catatan ? "Catatan: $catatan" : '');
            NotifikasiController::create($userData['id_user'], 
                "Pengajuan " . ($approved ? 'Disetujui' : 'Ditolak'), $pesan, $tipe);
        }
        
        successResponse("Pengajuan berhasil " . ($approved ? 'disetujui' : 'ditolak') . " oleh Admin Fakultas");
    }
    
    /**
     * Approval by Admin Sekolah (for PKL applications)
     * PUT /pengajuan/{id}/approve-sekolah
     */
    public function approveBySekolah($id) {
        $authUser = requireRole(['admin_sekolah', 'admin']);
        $input = getJsonInput();
        
        $approved = $input['approved'] ?? false;
        $catatan = $input['catatan'] ?? null;
        
        // Verify this is a PKL application
        $stmt = $this->db->prepare("SELECT * FROM pengajuan WHERE id_pengajuan = ?");
        $stmt->execute([$id]);
        $pengajuan = $stmt->fetch();
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        if ($pengajuan['jenis_pengajuan'] !== 'PKL') {
            return errorResponse('Hanya pengajuan PKL yang dapat disetujui oleh Admin Sekolah', 400);
        }
        
        // Update approval status
        $idPembimbing = $input['id_pembimbing'] ?? null;
        
        // Update approval status and assign pembimbing if approved
        $status = $approved ? 'approved' : 'rejected';
        
        $query = "UPDATE pengajuan SET 
                    status_admin_sekolah = ?,
                    approved_by_sekolah = ?,
                    approved_at_sekolah = NOW(),
                    catatan_sekolah = ?";
        
        $params = [$status, $authUser['id_user'], $catatan];

        if ($approved && $idPembimbing) {
            $query .= ", id_guru_pembimbing = ?";
            $params[] = $idPembimbing;
        }

        $query .= " WHERE id_pengajuan = ?";
        $params[] = $id;
        
        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        
        // If approved, also update main status and generate document
        if ($approved) {
            $this->db->prepare("UPDATE pengajuan SET status_pengajuan = 'Disetujui' WHERE id_pengajuan = ?")
                     ->execute([$id]);
            
            // Auto-generate document
            CetakController::generateOnApproval($id);
        } elseif (!$approved) {
            $this->db->prepare("UPDATE pengajuan SET status_pengajuan = 'Ditolak' WHERE id_pengajuan = ?")
                     ->execute([$id]);
        }
        
        // Send notification to siswa
        $stmtUser = $this->db->prepare("
            SELECT s.id_user FROM pengajuan p
            JOIN siswa s ON p.id_siswa = s.id_siswa
            WHERE p.id_pengajuan = ?
        ");
        $stmtUser->execute([$id]);
        $userData = $stmtUser->fetch();
        
        if ($userData) {
            $tipe = $approved ? 'success' : 'warning';
            $pesan = $approved 
                ? 'Pengajuan PKL Anda telah disetujui oleh Admin Sekolah. Surat permohonan telah digenerate.'
                : 'Pengajuan PKL Anda ditolak oleh Admin Sekolah. ' . ($catatan ? "Catatan: $catatan" : '');
            NotifikasiController::create($userData['id_user'], 
                "Pengajuan " . ($approved ? 'Disetujui' : 'Ditolak'), $pesan, $tipe);
        }
        
        successResponse("Pengajuan berhasil " . ($approved ? 'disetujui' : 'ditolak') . " oleh Admin Sekolah");
    }
    
    /**
     * Get workflow status for a pengajuan
     * GET /pengajuan/{id}/workflow
     */
    public function getWorkflowStatus($id) {
        $authUser = requireAuth();
        
        $stmt = $this->db->prepare("
            SELECT p.id_pengajuan, p.jenis_pengajuan, p.status_pengajuan,
                   p.status_admin_fakultas, p.status_admin_sekolah,
                   p.approved_at_fakultas, p.approved_at_sekolah,
                   p.catatan_fakultas, p.catatan_sekolah,
                   uf.nama_lengkap as approved_by_fakultas_nama,
                   us.nama_lengkap as approved_by_sekolah_nama
            FROM pengajuan p
            LEFT JOIN user uf ON p.approved_by_fakultas = uf.id_user
            LEFT JOIN user us ON p.approved_by_sekolah = us.id_user
            WHERE p.id_pengajuan = ?
        ");
        $stmt->execute([$id]);
        $pengajuan = $stmt->fetch();
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        // Build workflow steps
        $steps = [];
        
        if ($pengajuan['jenis_pengajuan'] === 'Magang') {
            $steps[] = [
                'step' => 1,
                'title' => 'Pengajuan Disubmit',
                'status' => 'completed',
                'actor' => 'Mahasiswa'
            ];
            $steps[] = [
                'step' => 2,
                'title' => 'Review Admin Fakultas',
                'status' => $pengajuan['status_admin_fakultas'],
                'actor' => 'Admin Fakultas',
                'approved_by' => $pengajuan['approved_by_fakultas_nama'],
                'approved_at' => $pengajuan['approved_at_fakultas'],
                'catatan' => $pengajuan['catatan_fakultas']
            ];
        } else {
            $steps[] = [
                'step' => 1,
                'title' => 'Pengajuan Disubmit',
                'status' => 'completed',
                'actor' => 'Siswa'
            ];
            $steps[] = [
                'step' => 2,
                'title' => 'Review Admin Sekolah',
                'status' => $pengajuan['status_admin_sekolah'],
                'actor' => 'Admin Sekolah',
                'approved_by' => $pengajuan['approved_by_sekolah_nama'],
                'approved_at' => $pengajuan['approved_at_sekolah'],
                'catatan' => $pengajuan['catatan_sekolah']
            ];
        }
        
        $steps[] = [
            'step' => 3,
            'title' => 'Penugasan Pembimbing',
            'status' => $pengajuan['status_pengajuan'] === 'Disetujui' ? 'completed' : 'pending',
            'actor' => 'System'
        ];
        
        successResponse([
            'pengajuan' => $pengajuan,
            'workflow_steps' => $steps
        ]);
    }
}

