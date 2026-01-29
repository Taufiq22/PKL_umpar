<?php
/**
 * Environment Configuration - Sistem Manajemen Magang dan PKL UMPAR
 * 
 * Konfigurasi environment untuk development, staging, dan production
 */

// Detect environment (default: development)
$env = getenv('APP_ENV') ?: 'development';

// Environment-specific configurations
$config = [
    'development' => [
        'debug' => true,
        'display_errors' => true,
        'log_errors' => true,
        'db_host' => 'localhost',
        'db_name' => 'magang_umpar',
        'db_user' => 'root',
        'db_pass' => '',
        'jwt_secret' => 'dev_secret_key_change_in_production',
        'jwt_expiry' => 86400 * 7, // 7 days in development
        'cors_origin' => '*',
        'rate_limit_enabled' => false,
        'log_level' => 'debug',
    ],
    
    'staging' => [
        'debug' => true,
        'display_errors' => false,
        'log_errors' => true,
        'db_host' => getenv('DB_HOST') ?: 'localhost',
        'db_name' => getenv('DB_NAME') ?: 'magang_umpar_staging',
        'db_user' => getenv('DB_USER') ?: 'root',
        'db_pass' => getenv('DB_PASS') ?: '',
        'jwt_secret' => getenv('JWT_SECRET') ?: 'staging_secret_change_me',
        'jwt_expiry' => 86400, // 1 day
        'cors_origin' => getenv('CORS_ORIGIN') ?: '*',
        'rate_limit_enabled' => true,
        'log_level' => 'info',
    ],
    
    'production' => [
        'debug' => false,
        'display_errors' => false,
        'log_errors' => true,
        'db_host' => getenv('DB_HOST'),
        'db_name' => getenv('DB_NAME'),
        'db_user' => getenv('DB_USER'),
        'db_pass' => getenv('DB_PASS'),
        'jwt_secret' => getenv('JWT_SECRET'),
        'jwt_expiry' => 3600 * 4, // 4 hours
        'cors_origin' => getenv('CORS_ORIGIN') ?: 'https://magang.umpar.ac.id',
        'rate_limit_enabled' => true,
        'log_level' => 'error',
    ],
];

// Get current config
$currentConfig = $config[$env] ?? $config['development'];

// Apply PHP settings
ini_set('display_errors', $currentConfig['display_errors'] ? '1' : '0');
ini_set('log_errors', $currentConfig['log_errors'] ? '1' : '0');
error_reporting($currentConfig['debug'] ? E_ALL : E_ERROR | E_WARNING | E_PARSE);

// Define constants
define('APP_ENV', $env);
define('APP_DEBUG', $currentConfig['debug']);
define('DB_HOST', $currentConfig['db_host']);
define('DB_NAME', $currentConfig['db_name']);
define('DB_USER', $currentConfig['db_user']);
define('DB_PASS', $currentConfig['db_pass']);
define('JWT_SECRET', $currentConfig['jwt_secret']);
define('JWT_EXPIRY', $currentConfig['jwt_expiry']);
define('CORS_ORIGIN', $currentConfig['cors_origin']);
define('RATE_LIMIT_ENABLED', $currentConfig['rate_limit_enabled']);
define('LOG_LEVEL', $currentConfig['log_level']);

/**
 * Get config value
 */
function config($key, $default = null) {
    global $currentConfig;
    return $currentConfig[$key] ?? $default;
}

/**
 * Check if environment is production
 */
function isProduction() {
    return APP_ENV === 'production';
}

/**
 * Check if environment is development
 */
function isDevelopment() {
    return APP_ENV === 'development';
}

/**
 * Check if debug mode is enabled
 */
function isDebug() {
    return APP_DEBUG === true;
}
