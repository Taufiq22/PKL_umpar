<?php
/**
 * Rate Limiter Helper - Sistem Manajemen Magang dan PKL UMPAR
 * 
 * Mencegah brute force dan DDoS attacks
 */

class RateLimiter {
    private static $cacheDir = __DIR__ . '/../cache/rate_limits/';
    
    // Default limits
    private static $limits = [
        'default' => ['requests' => 100, 'window' => 60],      // 100 req/menit
        'auth' => ['requests' => 5, 'window' => 60],           // 5 login attempts/menit
        'register' => ['requests' => 3, 'window' => 300],      // 3 registrations/5 menit
        'upload' => ['requests' => 10, 'window' => 60],        // 10 uploads/menit
        'export' => ['requests' => 5, 'window' => 60],         // 5 exports/menit
    ];
    
    /**
     * Initialize cache directory
     */
    private static function initCacheDir() {
        if (!is_dir(self::$cacheDir)) {
            mkdir(self::$cacheDir, 0755, true);
        }
    }
    
    /**
     * Check if request is allowed
     * 
     * @param string $identifier User ID or IP address
     * @param string $endpoint Endpoint category (auth, register, upload, etc.)
     * @return bool True if allowed, false if rate limited
     */
    public static function isAllowed($identifier, $endpoint = 'default') {
        self::initCacheDir();
        
        $limit = self::$limits[$endpoint] ?? self::$limits['default'];
        $key = self::getKey($identifier, $endpoint);
        $data = self::getData($key);
        
        $now = time();
        $windowStart = $now - $limit['window'];
        
        // Clean old requests
        $data['requests'] = array_filter($data['requests'], function($timestamp) use ($windowStart) {
            return $timestamp > $windowStart;
        });
        
        // Check limit
        if (count($data['requests']) >= $limit['requests']) {
            // Log rate limit hit
            require_once __DIR__ . '/logger.php';
            Logger::security('Rate limit exceeded', [
                'identifier' => $identifier,
                'endpoint' => $endpoint,
                'requests' => count($data['requests']),
                'limit' => $limit['requests']
            ]);
            return false;
        }
        
        // Add current request
        $data['requests'][] = $now;
        self::saveData($key, $data);
        
        return true;
    }
    
    /**
     * Check and throw exception if rate limited
     */
    public static function check($identifier, $endpoint = 'default') {
        if (!self::isAllowed($identifier, $endpoint)) {
            $limit = self::$limits[$endpoint] ?? self::$limits['default'];
            http_response_code(429);
            echo json_encode([
                'success' => false,
                'message' => 'Terlalu banyak permintaan. Silakan tunggu ' . $limit['window'] . ' detik.',
                'retry_after' => $limit['window']
            ]);
            exit;
        }
    }
    
    /**
     * Get remaining requests for identifier
     */
    public static function getRemaining($identifier, $endpoint = 'default') {
        self::initCacheDir();
        
        $limit = self::$limits[$endpoint] ?? self::$limits['default'];
        $key = self::getKey($identifier, $endpoint);
        $data = self::getData($key);
        
        $now = time();
        $windowStart = $now - $limit['window'];
        
        // Count valid requests
        $validRequests = array_filter($data['requests'], function($timestamp) use ($windowStart) {
            return $timestamp > $windowStart;
        });
        
        return max(0, $limit['requests'] - count($validRequests));
    }
    
    /**
     * Reset rate limit for identifier
     */
    public static function reset($identifier, $endpoint = 'default') {
        self::initCacheDir();
        $key = self::getKey($identifier, $endpoint);
        $file = self::$cacheDir . $key . '.json';
        if (file_exists($file)) {
            unlink($file);
        }
    }
    
    /**
     * Get identifier from request (user ID or IP)
     */
    public static function getIdentifier($userId = null) {
        if ($userId) {
            return 'user_' . $userId;
        }
        return 'ip_' . self::getClientIP();
    }
    
    /**
     * Generate cache key
     */
    private static function getKey($identifier, $endpoint) {
        return md5($identifier . '_' . $endpoint);
    }
    
    /**
     * Get cached data
     */
    private static function getData($key) {
        $file = self::$cacheDir . $key . '.json';
        if (file_exists($file)) {
            $content = file_get_contents($file);
            return json_decode($content, true) ?: ['requests' => []];
        }
        return ['requests' => []];
    }
    
    /**
     * Save data to cache
     */
    private static function saveData($key, $data) {
        $file = self::$cacheDir . $key . '.json';
        file_put_contents($file, json_encode($data), LOCK_EX);
    }
    
    /**
     * Get client IP address
     */
    private static function getClientIP() {
        $headers = [
            'HTTP_CLIENT_IP',
            'HTTP_X_FORWARDED_FOR',
            'HTTP_X_FORWARDED',
            'REMOTE_ADDR'
        ];
        
        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                return trim($ips[0]);
            }
        }
        
        return 'unknown';
    }
    
    /**
     * Clean old cache files
     */
    public static function cleanCache($hours = 1) {
        self::initCacheDir();
        $files = glob(self::$cacheDir . '*.json');
        $cutoff = time() - ($hours * 3600);
        
        foreach ($files as $file) {
            if (filemtime($file) < $cutoff) {
                unlink($file);
            }
        }
    }
}
