<?php
require_once 'config/database.php';

class DashboardController {
    private $conn;

    public function __construct() {
        $this->conn = getDB();
    }

    public function getAdminStats() {
        try {
            // 1. Counter Utma
            $stats = [
                'total_mahasiswa' => 0,
                'total_siswa' => 0,
                'total_instansi' => 0,
                'pengajuan_aktif' => 0,
                'pengajuan_selesai' => 0,
                'chart_data' => []
            ];

            // Count Mahasiswa
            $query = "SELECT COUNT(*) as count FROM user WHERE role = 'mahasiswa' AND is_active = 1";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['total_mahasiswa'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

            // Count Siswa
            $query = "SELECT COUNT(*) as count FROM user WHERE role = 'siswa' AND is_active = 1";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['total_siswa'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

            // Count Instansi (distinct nama_instansi from pengajuan)
            // Or if there is a master instansi table, count that. 
            // Assuming for now we count distinct approved instansi names from pengajuan or just count active pengajuan instansi
            $query = "SELECT COUNT(DISTINCT nama_instansi) as count FROM pengajuan_magang";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['total_instansi'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

            // Count Pengajuan Aktif
            $query = "SELECT COUNT(*) as count FROM pengajuan_magang WHERE status_pengajuan = 'Disetujui' AND (status_selesai = 'Belum' OR status_selesai IS NULL)";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['pengajuan_aktif'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

             // Count Pengajuan Selesai
            $query = "SELECT COUNT(*) as count FROM pengajuan_magang WHERE status_selesai = 'Selesai'";
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            $stats['pengajuan_selesai'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

            // 2. Chart Data (Pengajuan per Bulan - Last 6 Months)
            // MySQL: DATE_FORMAT(tanggal_pengajuan, '%Y-%m')
            
            $query = "SELECT DATE_FORMAT(tanggal_pengajuan, '%Y-%m') as bulan, COUNT(*) as total 
                      FROM pengajuan_magang 
                      WHERE tanggal_pengajuan >= DATE_SUB(Now(), INTERVAL 6 MONTH)
                      GROUP BY DATE_FORMAT(tanggal_pengajuan, '%Y-%m')
                      ORDER BY bulan ASC";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            
            $chartData = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $chartData[] = $row;
            }
            $stats['chart_data'] = $chartData;

            http_response_code(200);
            echo json_encode($stats);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "message" => "Terjadi kesalahan server",
                "error" => $e->getMessage()
            ]);
        }
    }
}
?>
