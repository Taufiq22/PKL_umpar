<?php
/**
 * Reset Password untuk Admin Fakultas dan Admin Sekolah
 * 
 * Jalankan script ini via browser atau CLI untuk reset password
 * URL: http://localhost/magang_umpar/api/reset_admin_password.php
 */

header('Content-Type: application/json');

// Database configuration
$host = 'localhost';
$dbname = 'magang_umpar';
$username = 'root';
$password = '';

// Password baru yang akan di-set (ganti sesuai kebutuhan)
$newPassword = 'admin123'; // Password default untuk semua admin

try {
    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Hash password baru dengan bcrypt
    $hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
    
    echo "=== RESET PASSWORD ADMIN FAKULTAS & ADMIN SEKOLAH ===\n\n";
    echo "Password baru (plain): $newPassword\n";
    echo "Password baru (hashed): $hashedPassword\n\n";
    
    // ========================================
    // 1. Reset semua Admin Fakultas
    // ========================================
    $stmtFakultas = $pdo->prepare("
        UPDATE user 
        SET password = :password 
        WHERE role = 'admin_fakultas'
    ");
    $stmtFakultas->execute(['password' => $hashedPassword]);
    $countFakultas = $stmtFakultas->rowCount();
    
    echo "Admin Fakultas yang di-reset: $countFakultas\n";
    
    // List Admin Fakultas
    $listFakultas = $pdo->query("
        SELECT u.id_user, u.username, u.nama_lengkap, af.fakultas 
        FROM user u 
        LEFT JOIN admin_fakultas af ON u.id_user = af.id_user 
        WHERE u.role = 'admin_fakultas'
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\nDaftar Admin Fakultas:\n";
    foreach ($listFakultas as $admin) {
        echo "  - ID: {$admin['id_user']}, Username: {$admin['username']}, Nama: {$admin['nama_lengkap']}, Fakultas: {$admin['fakultas']}\n";
    }
    
    // ========================================
    // 2. Reset semua Admin Sekolah
    // ========================================
    $stmtSekolah = $pdo->prepare("
        UPDATE user 
        SET password = :password 
        WHERE role = 'admin_sekolah'
    ");
    $stmtSekolah->execute(['password' => $hashedPassword]);
    $countSekolah = $stmtSekolah->rowCount();
    
    echo "\nAdmin Sekolah yang di-reset: $countSekolah\n";
    
    // List Admin Sekolah
    $listSekolah = $pdo->query("
        SELECT u.id_user, u.username, u.nama_lengkap, asek.nama_sekolah 
        FROM user u 
        LEFT JOIN admin_sekolah asek ON u.id_user = asek.id_user 
        WHERE u.role = 'admin_sekolah'
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\nDaftar Admin Sekolah:\n";
    foreach ($listSekolah as $admin) {
        echo "  - ID: {$admin['id_user']}, Username: {$admin['username']}, Nama: {$admin['nama_lengkap']}, Sekolah: {$admin['nama_sekolah']}\n";
    }
    
    // ========================================
    // Summary
    // ========================================
    echo "\n=== SELESAI ===\n";
    echo "Total Admin Fakultas: $countFakultas\n";
    echo "Total Admin Sekolah: $countSekolah\n";
    echo "Password baru: $newPassword\n";
    echo "\nSilakan login dengan username masing-masing dan password: $newPassword\n";
    
    // Return JSON response juga
    $result = [
        'success' => true,
        'message' => 'Password berhasil direset',
        'new_password' => $newPassword,
        'admin_fakultas_count' => $countFakultas,
        'admin_sekolah_count' => $countSekolah,
        'admin_fakultas' => $listFakultas,
        'admin_sekolah' => $listSekolah
    ];
    
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    $result = [
        'success' => false,
        'message' => $e->getMessage()
    ];
}

// Output JSON
echo "\n\n--- JSON Response ---\n";
echo json_encode($result, JSON_PRETTY_PRINT);
