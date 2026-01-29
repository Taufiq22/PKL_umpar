<?php
/**
 * Konfigurasi Database
 */

// Only define if not already defined by environment.php
if (!defined('DB_HOST')) {
    define('DB_HOST', 'localhost');
}
if (!defined('DB_NAME')) {
    define('DB_NAME', 'magang_umpar');
}
if (!defined('DB_USER')) {
    define('DB_USER', 'root');
}
if (!defined('DB_PASS')) {
    define('DB_PASS', '');
}
if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', 'utf8mb4');
}

// JWT Secret Key - Use longer, random string for security
if (!defined('JWT_SECRET')) {
    define('JWT_SECRET', 'x7Kp9mNqR2sT5vW8yB3cF6hJ4lA0nE1iZuQwXr8Ym2Gd7Hk');
}
if (!defined('JWT_EXPIRY')) {
    define('JWT_EXPIRY', 60 * 60 * 24); // 24 jam
}

class Database {
    private static $instance = null;
    private $connection;

    private function __construct() {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . (defined('DB_CHARSET') ? DB_CHARSET : 'utf8mb4');
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];
            $this->connection = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // Return JSON error instead of die() to prevent HTML output
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Database connection failed: ' . $e->getMessage()
            ]);
            exit();
        }
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }
}

/**
 * Helper function untuk mendapatkan koneksi database
 */
function getDB() {
    return Database::getInstance()->getConnection();
}
