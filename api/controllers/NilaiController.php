<?php
/**
 * Nilai Controller
 * Disesuaikan dengan struktur database magang_umpar.sql
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/NotifikasiController.php';

class NilaiController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get nilai by pengajuan
     */
    public function getByPengajuan($idPengajuan) {
        requireAuth();
        
        $stmt = $this->db->prepare("SELECT * FROM nilai WHERE id_pengajuan = ?");
        $stmt->execute([$idPengajuan]);
        
        successResponse('Data nilai berhasil diambil', $stmt->fetchAll());
    }

    /**
     * Get all nilai for instansi
     */
    public function getAll() {
        $authUser = requireAuth();
        
        $sql = "SELECT n.*, p.jenis_pengajuan, p.posisi,
                       u_mhs.nama_lengkap as nama_mahasiswa,
                       u_siswa.nama_lengkap as nama_siswa
                FROM nilai n
                JOIN pengajuan p ON n.id_pengajuan = p.id_pengajuan
                LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                LEFT JOIN user u_mhs ON m.id_user = u_mhs.id_user
                LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                LEFT JOIN user u_siswa ON s.id_user = u_siswa.id_user";
        
        // Filter berdasarkan role
        if ($authUser['role'] === 'instansi') {
            $stmt = $this->db->prepare("SELECT id_instansi FROM instansi WHERE id_user = ?");
            $stmt->execute([$authUser['user_id']]);
            $inst = $stmt->fetch();
            $sql .= " WHERE p.id_instansi = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$inst['id_instansi'] ?? 0]);
        } else {
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
        }
        
        successResponse('Data nilai berhasil diambil', $stmt->fetchAll());
    }

    /**
     * Create nilai (sesuai dengan struktur database)
     */
    public function create() {
        $authUser = requireRole(['instansi']);
        $input = getJsonInput();
        
        $idPengajuan = $input['id_pengajuan'] ?? null;
        $jenisPenilai = $input['jenis_penilai'] ?? ($authUser['role'] === 'instansi' ? 'Instansi' : 'Dosen');
        $aspekPenilaian = $input['aspek_penilaian'] ?? null;
        $nilaiAngka = $input['nilai_angka'] ?? 0;
        $komentar = $input['komentar'] ?? null;
        $isFromInstansi = $authUser['role'] === 'instansi' ? 1 : 0;
        
        if (!$idPengajuan) {
            errorResponse('ID Pengajuan wajib diisi');
        }
        
        if (!$aspekPenilaian) {
            errorResponse('Aspek penilaian wajib diisi');
        }
        
        $stmt = $this->db->prepare("
            INSERT INTO nilai (id_pengajuan, jenis_penilai, aspek_penilaian, nilai_angka, komentar, is_from_instansi, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$idPengajuan, $jenisPenilai, $aspekPenilaian, $nilaiAngka, $komentar, $isFromInstansi]);
        $idNilai = $this->db->lastInsertId();
        
        // Auto-notification: Notify mahasiswa/siswa about new grade
        $stmtPengajuan = $this->db->prepare("
            SELECT p.*, m.id_user as id_user_mhs, s.id_user as id_user_siswa
            FROM pengajuan p
            LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
            LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
            WHERE p.id_pengajuan = ?
        ");
        $stmtPengajuan->execute([$idPengajuan]);
        $pengajuan = $stmtPengajuan->fetch();
        
        $idUserTarget = $pengajuan['id_user_mhs'] ?? $pengajuan['id_user_siswa'];
        if ($idUserTarget) {
            NotifikasiController::create(
                $idUserTarget,
                'Nilai Baru',
                "Nilai $aspekPenilaian telah diinput: $nilaiAngka",
                'success'
            );
        }
        
        successResponse('Nilai berhasil disimpan', ['id_nilai' => $idNilai]);
    }

    /**
     * Update nilai
     */
    public function update($id) {
        $authUser = requireRole(['instansi']);
        $input = getJsonInput();
        
        $updates = [];
        $params = [];
        
        $allowedFields = ['aspek_penilaian', 'nilai_angka', 'komentar'];
        
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
        
        $sql = "UPDATE nilai SET " . implode(', ', $updates) . " WHERE id_nilai = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        
        successResponse('Nilai berhasil diupdate');
    }

    /**
     * Delete nilai
     */
    public function delete($id) {
        requireRole(['instansi', 'admin']);
        
        $stmt = $this->db->prepare("DELETE FROM nilai WHERE id_nilai = ?");
        $stmt->execute([$id]);
        
        successResponse('Nilai berhasil dihapus');
    }
}
