<?php
/**
 * DEBUG SCRIPT - Test Login Directly
 * Access via browser: http://localhost/umpar_magang_dan_pkl/api/test_login.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'config/database.php';

header('Content-Type: application/json');

echo "<pre>";
echo "=== LOGIN DEBUG TEST ===\n\n";

try {
    $db = getDB();
    echo "✅ Database connection successful!\n\n";
    
    // Test 1: List all users in database
    echo "=== ALL USERS IN DATABASE ===\n";
    $stmt = $db->query("SELECT id_user, username, email, role, is_active, 
                        CASE 
                            WHEN password LIKE '\$2y\$%' THEN 'bcrypt'
                            WHEN LENGTH(password) = 32 THEN 'md5'
                            ELSE 'unknown'
                        END as password_type
                        FROM user LIMIT 20");
    $users = $stmt->fetchAll();
    
    foreach ($users as $u) {
        echo "ID: {$u['id_user']} | Username: {$u['username']} | Role: {$u['role']} | Active: {$u['is_active']} | PassType: {$u['password_type']}\n";
    }
    
    echo "\n=== MAHASISWA TABLE ===\n";
    $stmt = $db->query("SELECT m.id_mahasiswa, m.id_user, m.nim, u.username, u.role 
                        FROM mahasiswa m 
                        JOIN user u ON m.id_user = u.id_user LIMIT 10");
    $mhs = $stmt->fetchAll();
    foreach ($mhs as $m) {
        echo "MhsID: {$m['id_mahasiswa']} | UserID: {$m['id_user']} | NIM: {$m['nim']} | Username: {$m['username']}\n";
    }
    
    echo "\n=== SISWA TABLE ===\n";
    $stmt = $db->query("SELECT s.id_siswa, s.id_user, s.nisn, u.username, u.role 
                        FROM siswa s 
                        JOIN user u ON s.id_user = u.id_user LIMIT 10");
    $siswa = $stmt->fetchAll();
    foreach ($siswa as $s) {
        echo "SiswaID: {$s['id_siswa']} | UserID: {$s['id_user']} | NISN: {$s['nisn']} | Username: {$s['username']}\n";
    }
    
    echo "\n=== TEST LOGIN SIMULATION ===\n";
    
    // Test login with specific user
    $testIdentifier = 'budi_mhs';
    $testPassword = 'password123';
    $testRole = 'mahasiswa';
    
    echo "Testing login with: identifier='$testIdentifier', role='$testRole'\n";
    
    // Try by username
    $stmt = $db->prepare("SELECT * FROM user WHERE username = ? AND role = ?");
    $stmt->execute([$testIdentifier, $testRole]);
    $user = $stmt->fetch();
    
    if ($user) {
        echo "✅ User found by username!\n";
        echo "   ID: {$user['id_user']}, Name: {$user['nama_lengkap']}\n";
        echo "   Password hash (first 30 chars): " . substr($user['password'], 0, 30) . "...\n";
        
        // Test password
        $storedHash = $user['password'];
        
        // Check bcrypt
        if (strpos($storedHash, '$2y$') === 0 || strpos($storedHash, '$2a$') === 0) {
            echo "   Password type: bcrypt\n";
            $match = password_verify($testPassword, $storedHash);
        } elseif (strlen($storedHash) === 32 && ctype_xdigit($storedHash)) {
            echo "   Password type: MD5\n";
            echo "   MD5 of '$testPassword': " . md5($testPassword) . "\n";
            echo "   Stored hash: $storedHash\n";
            $match = (md5($testPassword) === $storedHash);
        } else {
            echo "   Password type: UNKNOWN\n";
            $match = false;
        }
        
        if ($match) {
            echo "✅ PASSWORD VERIFIED!\n";
        } else {
            echo "❌ PASSWORD MISMATCH!\n";
        }
    } else {
        echo "❌ User NOT found by username\n";
        
        // Try by NIM
        echo "\nTrying by NIM...\n";
        $stmt = $db->prepare("
            SELECT u.* FROM user u
            INNER JOIN mahasiswa m ON u.id_user = m.id_user
            WHERE m.nim = ? AND u.role = 'mahasiswa'
        ");
        $stmt->execute([$testIdentifier]);
        $user = $stmt->fetch();
        
        if ($user) {
            echo "✅ User found by NIM!\n";
        } else {
            echo "❌ User NOT found by NIM either\n";
        }
    }
    
    echo "\n=== TEST WITH ACTUAL NIM ===\n";
    $testNim = '2021001001'; // From mahasiswa table
    $stmt = $db->prepare("
        SELECT u.* FROM user u
        INNER JOIN mahasiswa m ON u.id_user = m.id_user
        WHERE m.nim = ?
    ");
    $stmt->execute([$testNim]);
    $user = $stmt->fetch();
    
    if ($user) {
        echo "✅ User found by NIM '$testNim': {$user['username']} ({$user['nama_lengkap']})\n";
    } else {
        echo "❌ No user found for NIM '$testNim'\n";
    }
    
} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString();
}

echo "</pre>";
