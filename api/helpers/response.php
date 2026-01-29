<?php
/**
 * Response Helpers
 */

/**
 * Send JSON response
 */
function jsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * Success response
 */
function successResponse($arg1, $arg2 = null, $meta = null) {
    $data = null;
    $message = null;
    
    // SMART DETECTION LOGIC
    // Case 1: First arg is Array/Object AND Second arg is String -> Pattern ($data, $message)
    // Used by: BimbinganController, KehadiranController
    if ((is_array($arg1) || is_object($arg1)) && is_string($arg2)) {
        $data = $arg1;
        $message = $arg2;
    }
    // Case 2: First arg is Array/Object AND Second arg is Null -> Pattern ($data)
    // Used by: Some Pengajuan/Data endpoints
    else if ((is_array($arg1) || is_object($arg1)) && $arg2 === null) {
        $data = $arg1;
    }
    // Case 3: First arg is String -> Pattern ($message, $data)
    // Used by: AuthController, UsersController, PengajuanController (Standard)
    else if (is_string($arg1)) {
        $message = $arg1;
        $data = $arg2;
    }
    // Fallback: Assume legacy ($message, $data)
    else {
        $message = $arg1; // Convert to string if needed
        $data = $arg2;
    }

    $response = [
        'success' => true,
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }

    if ($message !== null) {
        $response['message'] = $message;
    }
    
    if ($meta !== null) {
        $response['meta'] = $meta;
    }
    
    jsonResponse($response);
}

/**
 * Error response
 */
function errorResponse($message, $errors = null, $statusCode = 400) {
    // Handle legacy calls where 2nd param is status code
    if (is_int($errors)) {
        $statusCode = $errors;
        $errors = null;
    }

    $response = [
        'success' => false,
        'message' => $message,
    ];
    
    if ($errors !== null) {
        $response['errors'] = $errors;
    }
    
    jsonResponse($response, $statusCode);
}

/**
 * Get JSON input
 */
function getJsonInput() {
    $json = file_get_contents('php://input');
    return json_decode($json, true) ?? [];
}

/**
 * Get authenticated user from token
 */
function getAuthUser() {
    $headers = getallheaders();
    
    // Debug: Log headers received
    error_log("AUTH DEBUG: Headers received: " . print_r($headers, true));
    
    // Try multiple header key variations (case-insensitive issue)
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    // Also try Apache specific
    if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }
    
    // Also try redirect authorization (for some Apache setups)
    if (empty($authHeader) && isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }
    
    error_log("AUTH DEBUG: Auth header found: " . $authHeader);
    
    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        error_log("AUTH DEBUG: No valid Bearer token found");
        return null;
    }
    
    $token = substr($authHeader, 7);
    error_log("AUTH DEBUG: Token extracted: " . substr($token, 0, 20) . "...");
    
    try {
        // Simple JWT decode (for production, use a proper JWT library)
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            error_log("AUTH DEBUG: Token doesn't have 3 parts");
            return null;
        }
        
        $payload = json_decode(base64_decode($parts[1]), true);
        error_log("AUTH DEBUG: Payload decoded: " . print_r($payload, true));
        
        if (!$payload || !isset($payload['user_id']) || !isset($payload['exp'])) {
            error_log("AUTH DEBUG: Missing user_id or exp in payload");
            return null;
        }
        
        // Check expiry
        if ($payload['exp'] < time()) {
            error_log("AUTH DEBUG: Token expired. Exp: " . $payload['exp'] . ", Now: " . time());
            return null;
        }
        
        error_log("AUTH DEBUG: Token valid! User ID: " . $payload['user_id']);
        return $payload;
    } catch (Exception $e) {
        error_log("AUTH DEBUG: Exception: " . $e->getMessage());
        return null;
    }
}

/**
 * Require authentication
 */
function requireAuth() {
    $user = getAuthUser();
    if (!$user) {
        // Add debug info in development
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? 'NOT FOUND';
        errorResponse('Unauthorized - Token tidak valid atau expired. Debug: Header=' . substr($authHeader, 0, 30) . '...', null, 401);
    }
    return $user;
}

/**
 * Require specific role(s)
 */
function requireRole($roles) {
    $user = requireAuth();
    
    if (!is_array($roles)) {
        $roles = [$roles];
    }
    
    if (!in_array($user['role'], $roles)) {
        errorResponse('Forbidden - Anda tidak memiliki akses', null, 403);
    }
    
    return $user;
}

/**
 * Simple JWT encode
 */
function createToken($userId, $role) {
    $header = base64_encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    
    $payload = base64_encode(json_encode([
        'user_id' => $userId,
        'role' => $role,
        'exp' => time() + JWT_EXPIRY,
        'iat' => time(),
    ]));
    
    $signature = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    
    return "$header.$payload.$signature";
}
