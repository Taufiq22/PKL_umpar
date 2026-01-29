<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class CetakController {
    private $conn;

    public function __construct() {
        $this->conn = getDB();
    }

    // Get Rekap Data Mahasiswa
    public function rekapMahasiswa() {
        try {
            // Join mahasiswa, user, and latest pengajuan status
            $query = "SELECT 
                        m.nim, m.prodi, m.fakultas, m.semester,
                        u.nama_lengkap, u.id_user,
                        (SELECT status_pengajuan FROM pengajuan p WHERE p.id_mahasiswa = m.id_mahasiswa ORDER BY p.created_at DESC LIMIT 1) as status_magang
                      FROM mahasiswa m
                      JOIN user u ON m.id_user = u.id_user
                      ORDER BY m.prodi, u.nama_lengkap";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            successResponse('Data rekap mahasiswa berhasil diambil', $result);
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }

    // Get Rekap Data Siswa
    public function rekapSiswa() {
        try {
            $query = "SELECT 
                        s.nisn, s.jurusan, s.sekolah, s.kelas,
                        u.nama_lengkap, u.id_user,
                        (SELECT status_pengajuan FROM pengajuan p WHERE p.id_siswa = s.id_siswa ORDER BY p.created_at DESC LIMIT 1) as status_pkl
                      FROM siswa s
                      JOIN user u ON s.id_user = u.id_user
                      ORDER BY s.sekolah, s.jurusan, u.nama_lengkap";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            successResponse('Data rekap siswa berhasil diambil', $result);
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }

    // Get Rekap Nilai
    public function rekapNilai() {
        try {
            // Join nilai, participating students (mahasiswa/siswa), and instansi
            // Note: This assumes simplified Grade structure for recap
            // We'll fetch finalized grades associated with completed pengajuan
            
            $query = "SELECT 
                        pj.id_pengajuan, pj.jenis_pengajuan,
                        CASE 
                            WHEN pj.id_mahasiswa IS NOT NULL THEN (SELECT nama_lengkap FROM user u JOIN mahasiswa m ON m.id_user = u.id_user WHERE m.id_mahasiswa = pj.id_mahasiswa)
                            WHEN pj.id_siswa IS NOT NULL THEN (SELECT nama_lengkap FROM user u JOIN siswa s ON s.id_user = u.id_user WHERE s.id_siswa = pj.id_siswa)
                        END as nama_peserta,
                        i.nama_instansi,
                        (SELECT nilai_akhir FROM nilai n WHERE n.id_pengajuan = pj.id_pengajuan LIMIT 1) as nilai_akhir
                      FROM pengajuan pj
                      JOIN instansi i ON pj.id_instansi = i.id_instansi
                      WHERE pj.status_pengajuan = 'Selesai'
                      ORDER BY pj.created_at DESC";

            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            successResponse('Data rekap nilai berhasil diambil', $result);
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }

    /**
     * Get data for Surat Permohonan
     */
    public function suratPermohonan($id) {
        try {
            requireAuth(); // Only authenticated users
            
            $query = "SELECT 
                        pj.id_pengajuan, pj.jenis_pengajuan, pj.posisi,
                        pj.tanggal_mulai, pj.tanggal_selesai, pj.durasi_bulan,
                        pj.created_at as tanggal_pengajuan,
                        i.nama_instansi, i.alamat as alamat_instansi,
                        CASE 
                            WHEN pj.id_mahasiswa IS NOT NULL THEN (
                                SELECT JSON_OBJECT(
                                    'nama', u.nama_lengkap,
                                    'nim', m.nim,
                                    'prodi', m.prodi,
                                    'fakultas', m.fakultas,
                                    'semester', m.semester
                                ) FROM user u 
                                JOIN mahasiswa m ON m.id_user = u.id_user 
                                WHERE m.id_mahasiswa = pj.id_mahasiswa
                            )
                            WHEN pj.id_siswa IS NOT NULL THEN (
                                SELECT JSON_OBJECT(
                                    'nama', u.nama_lengkap,
                                    'nisn', s.nisn,
                                    'jurusan', s.jurusan,
                                    'sekolah', s.sekolah,
                                    'kelas', s.kelas
                                ) FROM user u 
                                JOIN siswa s ON s.id_user = u.id_user 
                                WHERE s.id_siswa = pj.id_siswa
                            )
                        END as data_peserta
                      FROM pengajuan pj
                      LEFT JOIN instansi i ON pj.id_instansi = i.id_instansi
                      WHERE pj.id_pengajuan = ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$result) {
                errorResponse('Pengajuan tidak ditemukan', null, 404);
            }
            
            // Parse JSON data_peserta
            if ($result['data_peserta']) {
                $result['peserta'] = json_decode($result['data_peserta'], true);
            }
            unset($result['data_peserta']);
            
            // Add nomor surat (generated)
            $result['nomor_surat'] = sprintf(
                '%03d/UMPAR/%s/%s',
                $result['id_pengajuan'],
                $result['jenis_pengajuan'] === 'Magang' ? 'MGG' : 'PKL',
                date('Y')
            );
            
            successResponse('Data surat permohonan berhasil diambil', $result);
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }

    /**
     * Get data for Surat Balasan
     */
    public function suratBalasan($id) {
        try {
            requireAuth();
            
            $query = "SELECT 
                        pj.id_pengajuan, pj.jenis_pengajuan, pj.posisi,
                        pj.tanggal_mulai, pj.tanggal_selesai, pj.durasi_bulan,
                        pj.status_pengajuan, pj.surat_balasan,
                        pj.updated_at as tanggal_verifikasi,
                        i.nama_instansi, i.alamat as alamat_instansi,
                        CASE 
                            WHEN pj.id_mahasiswa IS NOT NULL THEN (
                                SELECT u.nama_lengkap FROM user u 
                                JOIN mahasiswa m ON m.id_user = u.id_user 
                                WHERE m.id_mahasiswa = pj.id_mahasiswa
                            )
                            WHEN pj.id_siswa IS NOT NULL THEN (
                                SELECT u.nama_lengkap FROM user u 
                                JOIN siswa s ON s.id_user = u.id_user 
                                WHERE s.id_siswa = pj.id_siswa
                            )
                        END as nama_peserta,
                        CASE 
                            WHEN pj.id_dosen_pembimbing IS NOT NULL THEN (
                                SELECT u.nama_lengkap FROM user u 
                                JOIN dosen_pembimbing d ON d.id_user = u.id_user 
                                WHERE d.id_dosen = pj.id_dosen_pembimbing
                            )
                            WHEN pj.id_guru_pembimbing IS NOT NULL THEN (
                                SELECT u.nama_lengkap FROM user u 
                                JOIN guru_pembimbing g ON g.id_user = u.id_user 
                                WHERE g.id_guru = pj.id_guru_pembimbing
                            )
                        END as nama_pembimbing
                      FROM pengajuan pj
                      LEFT JOIN instansi i ON pj.id_instansi = i.id_instansi
                      WHERE pj.id_pengajuan = ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$result) {
                errorResponse('Pengajuan tidak ditemukan', null, 404);
            }
            
            if ($result['status_pengajuan'] !== 'Disetujui' && $result['status_pengajuan'] !== 'Selesai') {
                errorResponse('Surat balasan hanya tersedia untuk pengajuan yang disetujui');
            }
            
            // Add nomor surat balasan
            $result['nomor_surat'] = sprintf(
                '%03d/UMPAR/BLS/%s/%s',
                $result['id_pengajuan'],
                $result['jenis_pengajuan'] === 'Magang' ? 'MGG' : 'PKL',
                date('Y')
            );
            
            successResponse('Data surat balasan berhasil diambil', $result);
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }
    
    /**
     * Auto-generate documents on approval
     * Called internally when pengajuan is approved
     */
    public static function generateOnApproval($idPengajuan) {
        try {
            $db = getDB();
            
            // Get pengajuan data
            $stmt = $db->prepare("
                SELECT pj.*, i.nama_instansi, i.alamat as alamat_instansi,
                       CASE 
                           WHEN pj.id_mahasiswa IS NOT NULL THEN (
                               SELECT u.nama_lengkap FROM user u 
                               JOIN mahasiswa m ON m.id_user = u.id_user 
                               WHERE m.id_mahasiswa = pj.id_mahasiswa
                           )
                           WHEN pj.id_siswa IS NOT NULL THEN (
                               SELECT u.nama_lengkap FROM user u 
                               JOIN siswa s ON s.id_user = u.id_user 
                               WHERE s.id_siswa = pj.id_siswa
                           )
                       END as nama_peserta,
                       CASE 
                           WHEN pj.id_mahasiswa IS NOT NULL THEN (
                               SELECT m.nim FROM mahasiswa m 
                               WHERE m.id_mahasiswa = pj.id_mahasiswa
                           )
                           WHEN pj.id_siswa IS NOT NULL THEN (
                               SELECT s.nisn FROM siswa s 
                               WHERE s.id_siswa = pj.id_siswa
                           )
                       END as id_peserta,
                       CASE 
                           WHEN pj.id_mahasiswa IS NOT NULL THEN (
                               SELECT m.prodi FROM mahasiswa m 
                               WHERE m.id_mahasiswa = pj.id_mahasiswa
                           )
                           WHEN pj.id_siswa IS NOT NULL THEN (
                               SELECT s.jurusan FROM siswa s 
                               WHERE s.id_siswa = pj.id_siswa
                           )
                       END as prodi_jurusan
                FROM pengajuan pj
                LEFT JOIN instansi i ON pj.id_instansi = i.id_instansi
                WHERE pj.id_pengajuan = ?
            ");
            $stmt->execute([$idPengajuan]);
            $data = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$data) {
                return false;
            }
            
            // Generate document filename
            $timestamp = date('YmdHis');
            $jenis = $data['jenis_pengajuan'] === 'Magang' ? 'MGG' : 'PKL';
            $filename = "surat_permohonan_{$jenis}_{$idPengajuan}_{$timestamp}.html";
            
            // Create uploads directory if not exists
            $uploadDir = __DIR__ . '/../uploads/documents/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            
            // Generate HTML document
            $html = self::generateSuratPermohonanHTML($data);
            $filepath = $uploadDir . $filename;
            file_put_contents($filepath, $html);
            
            // Save document path to database
            $updateStmt = $db->prepare("
                UPDATE pengajuan 
                SET surat_permohonan = ?, 
                    document_generated_at = NOW() 
                WHERE id_pengajuan = ?
            ");
            $updateStmt->execute([$filename, $idPengajuan]);
            
            return [
                'success' => true,
                'filename' => $filename,
                'filepath' => 'uploads/documents/' . $filename
            ];
            
        } catch (Exception $e) {
            error_log("Error generating document: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Generate Surat Permohonan HTML
     */
    private static function generateSuratPermohonanHTML($data) {
        $nomorSurat = sprintf(
            '%03d/UMPAR/PMH/%s/%s',
            $data['id_pengajuan'],
            $data['jenis_pengajuan'] === 'Magang' ? 'MGG' : 'PKL',
            date('Y')
        );
        
        $tanggalSekarang = date('d F Y');
        $jenisKegiatan = $data['jenis_pengajuan'] === 'Magang' ? 'Magang' : 'Praktik Kerja Lapangan (PKL)';
        
        return <<<HTML
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Surat Permohonan {$jenisKegiatan}</title>
    <style>
        body {
            font-family: 'Times New Roman', Times, serif;
            font-size: 12pt;
            line-height: 1.5;
            margin: 2.5cm;
        }
        .header {
            text-align: center;
            border-bottom: 3px double #000;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 16pt;
            margin: 0;
        }
        .header h2 {
            font-size: 14pt;
            margin: 5px 0;
        }
        .header p {
            font-size: 10pt;
            margin: 0;
        }
        .content {
            text-align: justify;
        }
        .signature {
            margin-top: 50px;
            text-align: right;
        }
        .signature-box {
            display: inline-block;
            text-align: center;
            width: 250px;
        }
        .nomor-surat {
            text-align: left;
            margin-bottom: 20px;
        }
        table.data {
            margin: 20px 0;
            border-collapse: collapse;
        }
        table.data td {
            padding: 5px 10px;
            vertical-align: top;
        }
        table.data td:first-child {
            width: 150px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>UNIVERSITAS MUHAMMADIYAH PAREPARE</h1>
        <h2>FAKULTAS TEKNIK INFORMATIKA</h2>
        <p>Jl. Jend. Ahmad Yani KM. 6 Parepare, Sulawesi Selatan 91131</p>
        <p>Telp: (0421) 22757 | Email: info@umpar.ac.id</p>
    </div>
    
    <div class="nomor-surat">
        <table>
            <tr>
                <td style="width: 80px;">Nomor</td>
                <td>: {$nomorSurat}</td>
            </tr>
            <tr>
                <td>Lampiran</td>
                <td>: -</td>
            </tr>
            <tr>
                <td>Perihal</td>
                <td>: <b>Permohonan {$jenisKegiatan}</b></td>
            </tr>
        </table>
    </div>
    
    <div class="content">
        <p>Kepada Yth.<br>
        <b>{$data['nama_instansi']}</b><br>
        {$data['alamat_instansi']}</p>
        
        <p>Dengan hormat,</p>
        
        <p>Sehubungan dengan program {$jenisKegiatan} yang diwajibkan bagi mahasiswa/siswa kami, dengan ini kami mohon kesediaan Bapak/Ibu untuk dapat menerima mahasiswa/siswa kami untuk melaksanakan {$jenisKegiatan} di instansi yang Bapak/Ibu pimpin.</p>
        
        <p>Adapun data mahasiswa/siswa yang bersangkutan adalah sebagai berikut:</p>
        
        <table class="data">
            <tr>
                <td>Nama</td>
                <td>: {$data['nama_peserta']}</td>
            </tr>
            <tr>
                <td>NIM/NISN</td>
                <td>: {$data['id_peserta']}</td>
            </tr>
            <tr>
                <td>Prodi/Jurusan</td>
                <td>: {$data['prodi_jurusan']}</td>
            </tr>
            <tr>
                <td>Posisi</td>
                <td>: {$data['posisi']}</td>
            </tr>
            <tr>
                <td>Periode</td>
                <td>: {$data['tanggal_mulai']} s/d {$data['tanggal_selesai']}</td>
            </tr>
            <tr>
                <td>Durasi</td>
                <td>: {$data['durasi_bulan']} bulan</td>
            </tr>
        </table>
        
        <p>Demikian surat permohonan ini kami sampaikan. Atas perhatian dan kerjasamanya, kami ucapkan terima kasih.</p>
    </div>
    
    <div class="signature">
        <p>Parepare, {$tanggalSekarang}</p>
        <div class="signature-box">
            <p>Koordinator {$jenisKegiatan}</p>
            <br><br><br><br>
            <p><u>________________________</u></p>
            <p>NIP. ________________</p>
        </div>
    </div>
</body>
</html>
HTML;
    }
    
    /**
     * Get list of generated documents for a pengajuan
     */
    public function getDocuments($id) {
        try {
            requireAuth();
            
            $stmt = $this->conn->prepare("
                SELECT id_pengajuan, surat_permohonan, surat_balasan, 
                       document_generated_at, status_pengajuan
                FROM pengajuan 
                WHERE id_pengajuan = ?
            ");
            $stmt->execute([$id]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$result) {
                errorResponse('Pengajuan tidak ditemukan', null, 404);
            }
            
            $documents = [];
            
            if ($result['surat_permohonan']) {
                $documents[] = [
                    'type' => 'surat_permohonan',
                    'filename' => $result['surat_permohonan'],
                    'url' => '/api/uploads/documents/' . $result['surat_permohonan'],
                    'generated_at' => $result['document_generated_at']
                ];
            }
            
            if ($result['surat_balasan']) {
                $documents[] = [
                    'type' => 'surat_balasan',
                    'filename' => $result['surat_balasan'],
                    'url' => '/api/uploads/documents/' . $result['surat_balasan']
                ];
            }
            
            successResponse('Daftar dokumen berhasil diambil', [
                'pengajuan_id' => $id,
                'status' => $result['status_pengajuan'],
                'documents' => $documents
            ]);
            
        } catch (Exception $e) {
            errorResponse('Gagal mengambil data: ' . $e->getMessage());
        }
    }
}

