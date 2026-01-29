<?php
/**
 * Security Helper - Sistem Manajemen Magang dan PKL UMPAR
 * 
 * Input sanitization, XSS prevention, dan security utilities
 */

class Security {
    /**
     * Sanitize string input - remove HTML tags and special chars
     */
    public static function sanitizeString($input) {
        if ($input === null) return null;
        
        $input = trim($input);
        $input = strip_tags($input);
        $input = htmlspecialchars($input, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        
        return $input;
    }
    
    /**
     * Sanitize email
     */
    public static function sanitizeEmail($email) {
        if ($email === null) return null;
        
        $email = filter_var($email, FILTER_SANITIZE_EMAIL);
        return filter_var($email, FILTER_VALIDATE_EMAIL) ? $email : null;
    }
    
    /**
     * Sanitize integer
     */
    public static function sanitizeInt($input) {
        if ($input === null) return null;
        return filter_var($input, FILTER_SANITIZE_NUMBER_INT);
    }
    
    /**
     * Sanitize float
     */
    public static function sanitizeFloat($input) {
        if ($input === null) return null;
        return filter_var($input, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
    }
    
    /**
     * Sanitize URL
     */
    public static function sanitizeUrl($url) {
        if ($url === null) return null;
        
        $url = filter_var($url, FILTER_SANITIZE_URL);
        return filter_var($url, FILTER_VALIDATE_URL) ? $url : null;
    }
    
    /**
     * Sanitize filename - remove dangerous characters
     */
    public static function sanitizeFilename($filename) {
        if ($filename === null) return null;
        
        // Remove path info
        $filename = basename($filename);
        
        // Remove dangerous characters
        $filename = preg_replace('/[^a-zA-Z0-9_\-\.]/', '_', $filename);
        
        // Prevent double extensions
        $filename = preg_replace('/\.+/', '.', $filename);
        
        return $filename;
    }
    
    /**
     * Sanitize array recursively
     */
    public static function sanitizeArray($array) {
        if (!is_array($array)) {
            return self::sanitizeString($array);
        }
        
        $result = [];
        foreach ($array as $key => $value) {
            $key = self::sanitizeString($key);
            $result[$key] = self::sanitizeArray($value);
        }
        
        return $result;
    }
    
    /**
     * Validate and sanitize JSON input
     */
    public static function getSecureJsonInput() {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return null;
        }
        
        return self::sanitizeArray($data);
    }
    
    /**
     * Validate password strength
     */
    public static function validatePasswordStrength($password) {
        $errors = [];
        
        if (strlen($password) < 8) {
            $errors[] = 'Password minimal 8 karakter';
        }
        
        if (!preg_match('/[A-Z]/', $password)) {
            $errors[] = 'Password harus mengandung huruf besar';
        }
        
        if (!preg_match('/[a-z]/', $password)) {
            $errors[] = 'Password harus mengandung huruf kecil';
        }
        
        if (!preg_match('/[0-9]/', $password)) {
            $errors[] = 'Password harus mengandung angka';
        }
        
        return $errors;
    }
    
    /**
     * Hash password securely
     */
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }
    
    /**
     * Verify password
     */
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    /**
     * Generate CSRF token
     */
    public static function generateCsrfToken() {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        $token = bin2hex(random_bytes(32));
        $_SESSION['csrf_token'] = $token;
        $_SESSION['csrf_token_time'] = time();
        
        return $token;
    }
    
    /**
     * Validate CSRF token
     */
    public static function validateCsrfToken($token, $maxAge = 3600) {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        if (!isset($_SESSION['csrf_token']) || !isset($_SESSION['csrf_token_time'])) {
            return false;
        }
        
        if (time() - $_SESSION['csrf_token_time'] > $maxAge) {
            return false;
        }
        
        return hash_equals($_SESSION['csrf_token'], $token);
    }
    
    /**
     * Generate random token
     */
    public static function generateToken($length = 32) {
        return bin2hex(random_bytes($length / 2));
    }
    
    /**
     * Check if request is from allowed origin
     */
    public static function checkOrigin($allowedOrigins = []) {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        
        if (empty($allowedOrigins)) {
            return true; // Allow all if no restrictions
        }
        
        return in_array($origin, $allowedOrigins);
    }
    
    /**
     * Rate of suspicious patterns in input
     */
    public static function detectSuspiciousInput($input) {
        $patterns = [
            '/(\bunion\b.*\bselect\b)/i',  // SQL injection
            '/<script[^>]*>/i',              // XSS
            '/javascript:/i',                // JavaScript injection
            '/on\w+\s*=/i',                  // Event handlers
            '/(\bexec\b|\bsystem\b)/i',      // Command injection
            '/\.\.\//',                      // Path traversal
        ];
        
        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $input)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Log security event
     */
    public static function logSecurityEvent($event, $details = []) {
        require_once __DIR__ . '/logger.php';
        Logger::security($event, $details);
    }
}
