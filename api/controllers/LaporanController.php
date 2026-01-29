<?php
/**
 * Laporan Controller
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/NotifikasiController.php';

class LaporanController {
    private $db;

    public function __construct() {
        $this->db = getDB();
    }

    /**
     * Get all laporan
     */
    public function getAll() {
        $authUser = requireAuth();
        
        $idPengajuan = $_GET['id_pengajuan'] ?? null;
        $jenis = $_GET['jenis'] ?? null;
        
        $sql = "SELECT * FROM laporan WHERE 1=1";
        $params = [];
        
        if ($idPengajuan) {
            $sql .= " AND id_pengajuan = ?";
            $params[] = $idPengajuan;
        }
        
        if ($jenis) {
            $sql .= " AND jenis_laporan = ?";
            $params[] = $jenis;
        }
        
        $sql .= " ORDER BY tanggal DESC, created_at DESC";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        
        successResponse('Data laporan berhasil diambil', $stmt->fetchAll());
    }

    /**
     * Create laporan
     * Only mahasiswa/siswa can create reports
     */
    public function create() {
        $authUser = requireAuth();
        
        // Permission check: Only mahasiswa/siswa can create reports
        if (!in_array($authUser['role'], ['mahasiswa', 'siswa'])) {
            errorResponse('Hanya mahasiswa/siswa yang dapat membuat laporan', 403);
        }
        
        $input = getJsonInput();
        
        $idPengajuan = $input['id_pengajuan'] ?? null;
        $jenisLaporan = $input['jenis_laporan'] ?? 'Harian';
        $tanggal = $input['tanggal'] ?? date('Y-m-d');
        $kegiatan = $input['kegiatan'] ?? '';
        $fileLaporan = $input['file_laporan'] ?? null;
        
        if (!$idPengajuan || !$kegiatan) {
            errorResponse('ID Pengajuan dan kegiatan wajib diisi');
        }
        
        $stmt = $this->db->prepare("
            INSERT INTO laporan (id_pengajuan, jenis_laporan, tanggal, kegiatan, file_laporan, status, created_at) 
            VALUES (?, ?, ?, ?, ?, 'Pending', NOW())
        ");
        $stmt->execute([$idPengajuan, $jenisLaporan, $tanggal, $kegiatan, $fileLaporan]);
        $idLaporan = $this->db->lastInsertId();
        
        // Auto-notification: Notify pembimbing about new report
        $stmtPengajuan = $this->db->prepare("
            SELECT p.id_dosen_pembimbing, p.id_guru_pembimbing,
                   dp.id_user as id_user_dosen, gp.id_user as id_user_guru
            FROM pengajuan p
            LEFT JOIN dosen_pembimbing dp ON p.id_dosen_pembimbing = dp.id_dosen
            LEFT JOIN guru_pembimbing gp ON p.id_guru_pembimbing = gp.id_guru
            WHERE p.id_pengajuan = ?
        ");
        $stmtPengajuan->execute([$idPengajuan]);
        $pengajuan = $stmtPengajuan->fetch();
        
        $idUserPembimbing = $pengajuan['id_user_dosen'] ?? $pengajuan['id_user_guru'];
        if ($idUserPembimbing) {
            NotifikasiController::create(
                $idUserPembimbing,
                'Laporan Baru',
                "Ada laporan $jenisLaporan baru yang perlu direview",
                'info'
            );
        }
        
        successResponse('Laporan berhasil dibuat', ['id_laporan' => $idLaporan]);
    }

    /**
     * Review laporan
     */
    public function review($id) {
        $authUser = requireRole(['dosen', 'guru', 'instansi', 'admin']);
        $input = getJsonInput();
        
        $status = $input['status'] ?? 'Sesuai';
        $komentar = $input['komentar_pembimbing'] ?? null;
        
        $stmt = $this->db->prepare("UPDATE laporan SET status = ?, komentar_pembimbing = ? WHERE id_laporan = ?");
        $stmt->execute([$status, $komentar, $id]);
        
        // Auto-notification: Notify mahasiswa/siswa about review result
        $stmtLaporan = $this->db->prepare("
            SELECT l.*, p.id_mahasiswa, p.id_siswa,
                   m.id_user as id_user_mhs, s.id_user as id_user_siswa
            FROM laporan l
            JOIN pengajuan p ON l.id_pengajuan = p.id_pengajuan
            LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
            LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
            WHERE l.id_laporan = ?
        ");
        $stmtLaporan->execute([$id]);
        $laporan = $stmtLaporan->fetch();
        
        $idUserTarget = $laporan['id_user_mhs'] ?? $laporan['id_user_siswa'];
        if ($idUserTarget) {
            $tipe = $status === 'Sesuai' ? 'success' : 'warning';
            $pesan = $status === 'Sesuai' 
                ? 'Laporan Anda telah disetujui.'
                : 'Laporan Anda perlu revisi. ' . ($komentar ? "Catatan: $komentar" : '');
            NotifikasiController::create($idUserTarget, "Laporan $status", $pesan, $tipe);
        }
        
        successResponse('Laporan berhasil direview');
    }
}
