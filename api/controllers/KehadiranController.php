<?php
/**
 * KehadiranController - Attendance Management
 * UMPAR Magang & PKL System
 * 
 * Handles daily attendance tracking for mahasiswa and siswa
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

class KehadiranController {
    
    /**
     * Get attendance list for a specific pengajuan
     * GET /kehadiran/{id_pengajuan}
     */
    public function getByPengajuan($idPengajuan) {
        $user = requireAuth();
        $db = getDB();
        
        // Verify user has access to this pengajuan
        $checkQuery = "SELECT p.*, 
                        m.fakultas, s.nama_sekolah,
                        CASE 
                            WHEN p.jenis_pengajuan = 'Magang' THEN m.id_user
                            ELSE s.id_user
                        END as id_user_pemilik
                       FROM pengajuan p
                       LEFT JOIN mahasiswa m ON p.id_mahasiswa = m.id_mahasiswa
                       LEFT JOIN siswa s ON p.id_siswa = s.id_siswa
                       WHERE p.id_pengajuan = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$idPengajuan]);
        $pengajuan = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        // Check access rights
        $hasAccess = false;
        $userId = $user['user_id'];
        
        if ($user['role'] === 'admin') {
            $hasAccess = true;
        } elseif (in_array($user['role'], ['mahasiswa', 'siswa'])) {
            if ($pengajuan['id_user_pemilik'] == $userId) {
                $hasAccess = true;
            }
        } elseif ($user['role'] === 'admin_fakultas') {
             // Get admin profile
             $stmt = $db->prepare("SELECT fakultas FROM admin_fakultas WHERE id_user = ?");
             $stmt->execute([$userId]);
             $adminFak = $stmt->fetch(PDO::FETCH_ASSOC);
             if ($adminFak && $pengajuan['jenis_pengajuan'] == 'Magang' && $pengajuan['fakultas'] == $adminFak['fakultas']) {
                 $hasAccess = true;
             }
        } elseif ($user['role'] === 'admin_sekolah') {
             // Get admin profile
             $stmt = $db->prepare("SELECT nama_sekolah FROM admin_sekolah WHERE id_user = ?");
             $stmt->execute([$userId]);
             $adminSek = $stmt->fetch(PDO::FETCH_ASSOC);
             if ($adminSek && $pengajuan['jenis_pengajuan'] == 'PKL' && $pengajuan['nama_sekolah'] == $adminSek['nama_sekolah']) {
                 $hasAccess = true;
             }
        } elseif ($user['role'] === 'dosen') {
             $stmt = $db->prepare("SELECT id_dosen FROM dosen_pembimbing WHERE id_user = ?");
             $stmt->execute([$userId]);
             $dosenId = $stmt->fetchColumn();
             if ($dosenId && $pengajuan['id_dosen_pembimbing'] == $dosenId) {
                 $hasAccess = true;
             }
        } elseif ($user['role'] === 'guru') {
             $stmt = $db->prepare("SELECT id_guru FROM guru_pembimbing WHERE id_user = ?");
             $stmt->execute([$userId]);
             $guruId = $stmt->fetchColumn();
             if ($guruId && $pengajuan['id_guru_pembimbing'] == $guruId) {
                 $hasAccess = true;
             }
        } elseif ($user['role'] === 'instansi') {
             $stmt = $db->prepare("SELECT id_instansi FROM instansi WHERE id_user = ?");
             $stmt->execute([$userId]);
             $instansiId = $stmt->fetchColumn();
             if ($instansiId && $pengajuan['id_instansi'] == $instansiId) {
                 $hasAccess = true;
             }
        }
        
        if (!$hasAccess) {
            return errorResponse('Anda tidak memiliki akses', 403);
        }
        
        // Get attendance records
        $query = "SELECT * FROM kehadiran 
                  WHERE id_pengajuan = ? 
                  ORDER BY tanggal DESC";
        $stmt = $db->prepare($query);
        $stmt->execute([$idPengajuan]);
        $kehadiran = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return successResponse($kehadiran, 'Data kehadiran berhasil diambil');
    }
    
    /**
     * Get attendance statistics for a pengajuan
     * GET /kehadiran/{id_pengajuan}/statistik
     */
    public function getStatistik($idPengajuan) {
        $user = requireAuth();
        $db = getDB();
        
        // Verify access (similar to getByPengajuan)
        $checkQuery = "SELECT id_pengajuan FROM pengajuan WHERE id_pengajuan = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$idPengajuan]);
        if (!$stmt->fetch()) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        // Get statistics
        $query = "SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status_kehadiran = 'Hadir' THEN 1 ELSE 0 END) as hadir,
                    SUM(CASE WHEN status_kehadiran = 'Izin' THEN 1 ELSE 0 END) as izin,
                    SUM(CASE WHEN status_kehadiran = 'Sakit' THEN 1 ELSE 0 END) as sakit,
                    SUM(CASE WHEN status_kehadiran = 'Alpha' THEN 1 ELSE 0 END) as alpha
                  FROM kehadiran 
                  WHERE id_pengajuan = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$idPengajuan]);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Calculate percentage
        $total = (int)$stats['total'];
        $stats['persentase_hadir'] = $total > 0 ? round(($stats['hadir'] / $total) * 100, 2) : 0;
        
        return successResponse($stats, 'Statistik kehadiran berhasil diambil');
    }
    
    /**
     * Input new attendance record
     * POST /kehadiran
     */
    public function create() {
        $user = requireAuth();
        
        // Only mahasiswa, siswa, or instansi can input attendance
        if (!in_array($user['role'], ['mahasiswa', 'siswa', 'instansi', 'admin'])) {
            return errorResponse('Anda tidak memiliki akses untuk input kehadiran', 403);
        }
        
        $data = getJsonInput();
        
        // Validate required fields
        if (empty($data['id_pengajuan']) || empty($data['tanggal']) || empty($data['status_kehadiran'])) {
            return errorResponse('ID Pengajuan, tanggal, dan status kehadiran wajib diisi', 400);
        }
        
        // Validate status
        $validStatus = ['Hadir', 'Izin', 'Sakit', 'Alpha'];
        if (!in_array($data['status_kehadiran'], $validStatus)) {
            return errorResponse('Status kehadiran tidak valid', 400);
        }
        
        $db = getDB();
        
        // Check if attendance for this date already exists
        $checkQuery = "SELECT id_kehadiran FROM kehadiran 
                       WHERE id_pengajuan = ? AND tanggal = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$data['id_pengajuan'], $data['tanggal']]);
        if ($stmt->fetch()) {
            return errorResponse('Kehadiran untuk tanggal ini sudah ada', 400);
        }
        
        // Insert attendance
        $query = "INSERT INTO kehadiran 
                  (id_pengajuan, tanggal, status_kehadiran, jam_masuk, jam_keluar, keterangan, lokasi_checkin)
                  VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data['id_pengajuan'],
            $data['tanggal'],
            $data['status_kehadiran'],
            $data['jam_masuk'] ?? null,
            $data['jam_keluar'] ?? null,
            $data['keterangan'] ?? null,
            $data['lokasi_checkin'] ?? null
        ]);
        
        if ($result) {
            $newId = $db->lastInsertId();
            return successResponse(['id_kehadiran' => $newId], 'Kehadiran berhasil dicatat', 201);
        }
        
        return errorResponse('Gagal mencatat kehadiran', 500);
    }
    
    /**
     * Update attendance record
     * PUT /kehadiran/{id}
     */
    public function update($id) {
        $user = requireAuth();
        $db = getDB();
        
        // Check if record exists
        $checkQuery = "SELECT * FROM kehadiran WHERE id_kehadiran = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$id]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$existing) {
            return errorResponse('Data kehadiran tidak ditemukan', 404);
        }
        
        $data = getJsonInput();
        
        // Build update query dynamically
        $updates = [];
        $params = [];
        
        $allowedFields = ['status_kehadiran', 'jam_masuk', 'jam_keluar', 'keterangan', 'lokasi_checkin'];
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                $updates[] = "$field = ?";
                $params[] = $data[$field];
            }
        }
        
        if (empty($updates)) {
            return errorResponse('Tidak ada data yang diupdate', 400);
        }
        
        $params[] = $id;
        $query = "UPDATE kehadiran SET " . implode(', ', $updates) . " WHERE id_kehadiran = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute($params);
        
        if ($result) {
            return successResponse(null, 'Kehadiran berhasil diupdate');
        }
        
        return errorResponse('Gagal mengupdate kehadiran', 500);
    }
    
    /**
     * Delete attendance record
     * DELETE /kehadiran/{id}
     */
    public function delete($id) {
        $user = requireAuth();
        
        // Only admin can delete
        if ($user['role'] !== 'admin') {
            return errorResponse('Hanya admin yang dapat menghapus kehadiran', 403);
        }
        
        $db = getDB();
        $query = "DELETE FROM kehadiran WHERE id_kehadiran = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$id]);
        
        if ($result && $stmt->rowCount() > 0) {
            return successResponse(null, 'Kehadiran berhasil dihapus');
        }
        
        return errorResponse('Kehadiran tidak ditemukan', 404);
    }
    
    /**
     * Check-in for today with GPS validation
     * POST /kehadiran/checkin
     */
    public function checkin() {
        $user = requireAuth();
        
        if (!in_array($user['role'], ['mahasiswa', 'siswa'])) {
            return errorResponse('Hanya mahasiswa/siswa yang dapat check-in', 403);
        }
        
        $data = getJsonInput();
        
        if (empty($data['id_pengajuan'])) {
            return errorResponse('ID Pengajuan wajib diisi', 400);
        }
        
        $db = getDB();
        $today = date('Y-m-d');
        $currentTime = date('H:i:s');
        
        // Get pengajuan and instansi location
        $pengajuanQuery = "SELECT p.*, i.latitude as instansi_lat, i.longitude as instansi_lng, 
                          COALESCE(i.radius_absensi, 100) as radius_absensi
                          FROM pengajuan p
                          LEFT JOIN instansi i ON p.id_instansi = i.id_instansi
                          WHERE p.id_pengajuan = ?";
        $stmt = $db->prepare($pengajuanQuery);
        $stmt->execute([$data['id_pengajuan']]);
        $pengajuan = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$pengajuan) {
            return errorResponse('Pengajuan tidak ditemukan', 404);
        }
        
        // GPS Validation
        $latitude = isset($data['latitude']) ? floatval($data['latitude']) : null;
        $longitude = isset($data['longitude']) ? floatval($data['longitude']) : null;
        $akurasi = isset($data['akurasi']) ? intval($data['akurasi']) : null;
        $lokasiValid = 1;
        $jarakDariInstansi = null;
        
        // If instansi has GPS coordinates and user sent location
        if ($pengajuan['instansi_lat'] && $pengajuan['instansi_lng'] && $latitude && $longitude) {
            $jarakDariInstansi = $this->hitungJarak(
                $latitude, $longitude,
                floatval($pengajuan['instansi_lat']), 
                floatval($pengajuan['instansi_lng'])
            );
            
            $radius = intval($pengajuan['radius_absensi']);
            
            if ($jarakDariInstansi > $radius) {
                $lokasiValid = 0;
                // Optional: return error if strict validation
                // return errorResponse("Anda berada " . round($jarakDariInstansi) . "m dari lokasi instansi (maksimal {$radius}m)", 400);
            }
        }
        
        // Check if already checked in today
        $checkQuery = "SELECT * FROM kehadiran 
                       WHERE id_pengajuan = ? AND tanggal = ?";
        $stmt = $db->prepare($checkQuery);
        $stmt->execute([$data['id_pengajuan'], $today]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existing) {
            // If already checked in, update checkout time
            if ($existing['jam_keluar']) {
                return errorResponse('Anda sudah check-out hari ini', 400);
            }
            
            // Update checkout with GPS data
            $query = "UPDATE kehadiran SET 
                        jam_keluar = ?, 
                        latitude_checkout = ?, 
                        longitude_checkout = ?, 
                        akurasi_checkout = ?,
                        jarak_checkout = ?,
                        lokasi_valid_checkout = ?
                      WHERE id_kehadiran = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([
                $currentTime, 
                $latitude, 
                $longitude, 
                $akurasi,
                $jarakDariInstansi ? round($jarakDariInstansi) : null,
                $lokasiValid,
                $existing['id_kehadiran']
            ]);
            
            return successResponse([
                'jam_keluar' => $currentTime,
                'lokasi_valid' => $lokasiValid == 1,
                'jarak' => $jarakDariInstansi ? round($jarakDariInstansi) : null
            ], 'Check-out berhasil');
        }
        
        // Create new attendance with check-in and GPS data
        $query = "INSERT INTO kehadiran 
                  (id_pengajuan, tanggal, status_kehadiran, jam_masuk, 
                   latitude_checkin, longitude_checkin, akurasi_checkin, jarak_checkin, lokasi_valid_checkin)
                  VALUES (?, ?, 'Hadir', ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data['id_pengajuan'],
            $today,
            $currentTime,
            $latitude,
            $longitude,
            $akurasi,
            $jarakDariInstansi ? round($jarakDariInstansi) : null,
            $lokasiValid
        ]);
        
        if ($result) {
            return successResponse([
                'id_kehadiran' => $db->lastInsertId(),
                'jam_masuk' => $currentTime,
                'lokasi_valid' => $lokasiValid == 1,
                'jarak' => $jarakDariInstansi ? round($jarakDariInstansi) : null
            ], 'Check-in berhasil');
        }
        
        return errorResponse('Gagal check-in', 500);
    }
    
    /**
     * Calculate distance between two GPS coordinates using Haversine formula
     * Returns distance in meters
     */
    private function hitungJarak($lat1, $lng1, $lat2, $lng2) {
        $radiusBumi = 6371000; // meter
        
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        
        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLng / 2) * sin($dLng / 2);
        
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        
        return $radiusBumi * $c;
    }
    
    /**
     * Get today's attendance status
     * GET /kehadiran/today/{id_pengajuan}
     */
    public function getToday($idPengajuan) {
        $user = requireAuth();
        $db = getDB();
        
        $today = date('Y-m-d');
        $query = "SELECT * FROM kehadiran 
                  WHERE id_pengajuan = ? AND tanggal = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$idPengajuan, $today]);
        $kehadiran = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($kehadiran) {
            return successResponse($kehadiran, 'Data kehadiran hari ini');
        }
        
        return successResponse(null, 'Belum ada kehadiran hari ini');
    }
}
