<?php
/**
 * Logger Helper - Sistem Manajemen Magang dan PKL UMPAR
 * 
 * Logging untuk error, activity, dan security events
 */

class Logger {
    private static $logDir = __DIR__ . '/../logs/';
    
    /**
     * Initialize log directory
     */
    private static function initLogDir() {
        if (!is_dir(self::$logDir)) {
            mkdir(self::$logDir, 0755, true);
        }
    }
    
    /**
     * Log error message
     */
    public static function error($message, $context = []) {
        self::log('ERROR', $message, $context);
    }
    
    /**
     * Log warning message
     */
    public static function warning($message, $context = []) {
        self::log('WARNING', $message, $context);
    }
    
    /**
     * Log info message
     */
    public static function info($message, $context = []) {
        self::log('INFO', $message, $context);
    }
    
    /**
     * Log debug message (only in development)
     */
    public static function debug($message, $context = []) {
        if (getenv('APP_ENV') !== 'production') {
            self::log('DEBUG', $message, $context);
        }
    }
    
    /**
     * Log security event (login, logout, access denied)
     */
    public static function security($message, $context = []) {
        self::log('SECURITY', $message, $context, 'security.log');
    }
    
    /**
     * Log API request
     */
    public static function api($method, $endpoint, $userId = null, $statusCode = 200) {
        $context = [
            'method' => $method,
            'endpoint' => $endpoint,
            'user_id' => $userId,
            'status_code' => $statusCode,
            'ip' => self::getClientIP(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
        ];
        self::log('API', $endpoint, $context, 'api.log');
    }
    
    /**
     * Log activity (CRUD operations)
     */
    public static function activity($action, $entity, $entityId, $userId, $details = []) {
        $context = [
            'action' => $action,
            'entity' => $entity,
            'entity_id' => $entityId,
            'user_id' => $userId,
            'details' => $details,
            'ip' => self::getClientIP()
        ];
        self::log('ACTIVITY', "$action $entity", $context, 'activity.log');
    }
    
    /**
     * Core logging function
     */
    private static function log($level, $message, $context = [], $filename = 'app.log') {
        self::initLogDir();
        
        $logEntry = [
            'timestamp' => date('Y-m-d H:i:s'),
            'level' => $level,
            'message' => $message,
            'context' => $context
        ];
        
        $logFile = self::$logDir . date('Y-m-d') . '_' . $filename;
        $logLine = json_encode($logEntry) . "\n";
        
        file_put_contents($logFile, $logLine, FILE_APPEND | LOCK_EX);
    }
    
    /**
     * Get client IP address
     */
    private static function getClientIP() {
        $headers = [
            'HTTP_CLIENT_IP',
            'HTTP_X_FORWARDED_FOR',
            'HTTP_X_FORWARDED',
            'HTTP_X_CLUSTER_CLIENT_IP',
            'HTTP_FORWARDED_FOR',
            'HTTP_FORWARDED',
            'REMOTE_ADDR'
        ];
        
        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                return trim($ips[0]);
            }
        }
        
        return 'Unknown';
    }
    
    /**
     * Clean old logs (older than 30 days)
     */
    public static function cleanOldLogs($days = 30) {
        self::initLogDir();
        $files = glob(self::$logDir . '*.log');
        $cutoff = time() - ($days * 24 * 60 * 60);
        
        foreach ($files as $file) {
            if (filemtime($file) < $cutoff) {
                unlink($file);
            }
        }
    }
}
