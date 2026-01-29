<?php
/**
 * API REST - Aplikasi Manajemen Magang dan PKL
 * Universitas Muhammadiyah Parepare
 * 
 * Entry Point with Security Hardening
 */

// Include environment config first
require_once 'config/environment.php';

// Include config dan helpers
require_once 'config/database.php';
require_once 'helpers/response.php';
require_once 'helpers/logger.php';
require_once 'helpers/rate_limiter.php';
require_once 'helpers/security.php';

// Enhanced CORS headers
$corsOrigin = defined('CORS_ORIGIN') ? CORS_ORIGIN : '*';
header("Access-Control-Allow-Origin: " . $corsOrigin);
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("X-Content-Type-Options: nosniff");
header("X-Frame-Options: DENY");
header("X-XSS-Protection: 1; mode=block");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Apply rate limiting (if enabled)
if (defined('RATE_LIMIT_ENABLED') && RATE_LIMIT_ENABLED) {
    $identifier = RateLimiter::getIdentifier();
    RateLimiter::check($identifier, 'default');
}

// Get request info
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', trim($uri, '/'));

// Remove 'api' prefix if exists
$apiIndex = array_search('api', $uri);
if ($apiIndex !== false) {
    $uri = array_slice($uri, $apiIndex + 1);
}

$method = $_SERVER['REQUEST_METHOD'];

// Simple router
$endpoint = $uri[0] ?? '';
$action = $uri[1] ?? '';
$id = $uri[2] ?? null;

try {
    switch ($endpoint) {
        case 'auth':
            require_once 'controllers/AuthController.php';
            $controller = new AuthController();
            
            switch ($action) {
                case 'login':
                    if ($method === 'POST') {
                        $controller->login();
                    }
                    break;
                case 'register':
                    if ($method === 'POST') {
                        $controller->register();
                    }
                    break;
                case 'logout':
                    if ($method === 'POST') {
                        $controller->logout();
                    }
                    break;
                case 'profil':
                    if ($method === 'GET') {
                        $controller->getProfil();
                    } elseif ($method === 'PUT') {
                        // Check if it's password update
                        if ($id === 'password') {
                            $controller->updatePassword();
                        } else {
                            $controller->updateProfil();
                        }
                    }
                    break;
                default:
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;
            
        case 'pengajuan':
            require_once 'controllers/PengajuanController.php';
            $controller = new PengajuanController();
            
            if ($method === 'GET' && empty($action)) {
                $controller->getAll();
            } elseif ($method === 'GET' && is_numeric($action) && $id === 'workflow') {
                // GET /pengajuan/{id}/workflow
                $controller->getWorkflowStatus($action);
            } elseif ($method === 'GET' && is_numeric($action)) {
                $controller->getById($action);
            } elseif ($method === 'POST' && empty($action)) {
                $controller->create();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                if ($id === 'verifikasi') {
                    $controller->verifikasi($action);
                } elseif ($id === 'approve-fakultas') {
                    // PUT /pengajuan/{id}/approve-fakultas
                    $controller->approveByFakultas($action);
                } elseif ($id === 'approve-sekolah') {
                    // PUT /pengajuan/{id}/approve-sekolah
                    $controller->approveBySekolah($action);
                } else {
                    $controller->update($action);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;
            
        case 'laporan':
            require_once 'controllers/LaporanController.php';
            $controller = new LaporanController();
            
            if ($method === 'GET') {
                $controller->getAll();
            } elseif ($method === 'POST') {
                $controller->create();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                $controller->review($action);
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;
            
        case 'nilai':
            require_once 'controllers/NilaiController.php';
            $controller = new NilaiController();
            
            if ($method === 'GET' && is_numeric($action)) {
                $controller->getByPengajuan($action);
            } elseif ($method === 'POST') {
                $controller->create();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                $controller->update($action);
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;
            
        case 'notifikasi':
            require_once 'controllers/NotifikasiController.php';
            $controller = new NotifikasiController();
            
            if ($method === 'GET') {
                $controller->getAll();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                $controller->markAsRead($action);
            } elseif ($method === 'DELETE' && is_numeric($action)) {
                $controller->delete($action);
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;

        case 'users':
            require_once 'controllers/UsersController.php';
            $controller = new UsersController();
            
            if ($method === 'GET') {
                if (empty($action)) {
                    $controller->getAll();
                } elseif (is_numeric($action)) {
                    $controller->getById($action);
                }
            } elseif ($method === 'POST') {
                $controller->create();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                $controller->update($action);
            } elseif ($method === 'DELETE' && is_numeric($action)) {
                $controller->delete($action);
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;
            
        case 'cetak':
            require_once 'controllers/CetakController.php';
            $controller = new CetakController();
            
            if ($method === 'GET') {
                if ($action === 'mahasiswa') {
                    $controller->rekapMahasiswa();
                } elseif ($action === 'siswa') {
                    $controller->rekapSiswa();
                } elseif ($action === 'nilai') {
                    $controller->rekapNilai();
                } elseif ($action === 'surat-permohonan' && is_numeric($id)) {
                    $controller->suratPermohonan($id);
                } elseif ($action === 'surat-balasan' && is_numeric($id)) {
                    $controller->suratBalasan($id);
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            }
            break;

        case 'instansi':
            require_once 'controllers/InstansiController.php';
            $controller = new InstansiController();
            
            if ($method === 'GET') {
                if (empty($action)) {
                    $controller->getAll();
                } elseif (is_numeric($action)) {
                    $controller->getById($action);
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
            }
            break;

        case 'pembimbing':
            require_once 'controllers/PembimbingController.php';
            $controller = new PembimbingController();
            
            if ($method === 'GET') {
                if (empty($action)) {
                    $controller->getAll();
                } elseif ($action === 'dosen') {
                    $controller->getDosenPembimbing();
                } elseif ($action === 'guru') {
                    $controller->getGuruPembimbing();
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
            }
            break;

        case 'kehadiran':
            require_once 'controllers/KehadiranController.php';
            $controller = new KehadiranController();
            
            if ($method === 'GET') {
                if ($action === 'today' && is_numeric($id)) {
                    $controller->getToday($id);
                } elseif (is_numeric($action)) {
                    if ($id === 'statistik') {
                        $controller->getStatistik($action);
                    } else {
                        $controller->getByPengajuan($action);
                    }
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } elseif ($method === 'POST') {
                if ($action === 'checkin') {
                    $controller->checkin();
                } else {
                    $controller->create();
                }
            } elseif ($method === 'PUT' && is_numeric($action)) {
                $controller->update($action);
            } elseif ($method === 'DELETE' && is_numeric($action)) {
                $controller->delete($action);
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;

        case 'bimbingan':
            require_once 'controllers/BimbinganController.php';
            $controller = new BimbinganController();
            
            if ($method === 'GET') {
                if (empty($action)) {
                    $controller->getAll();
                } elseif ($action === 'pengajuan' && is_numeric($id)) {
                    $controller->getByPengajuan($id);
                } elseif (is_numeric($action)) {
                    $controller->getById($action);
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } elseif ($method === 'POST') {
                $controller->create();
            } elseif ($method === 'PUT' && is_numeric($action)) {
                if ($id === 'jadwal') {
                    $controller->setJadwal($action);
                } elseif ($id === 'selesai') {
                    $controller->selesai($action);
                } elseif ($id === 'rating') {
                    $controller->giveRating($action);
                } elseif ($id === 'batal') {
                    $controller->cancel($action);
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
            }
            break;

        case 'admin-fakultas':
            require_once 'controllers/AdminFakultasController.php';
            $controller = new AdminFakultasController();
            
            if ($method === 'GET') {
                if ($action === 'profil') {
                    $controller->getProfil();
                } elseif ($action === 'pengajuan') {
                    $controller->getPengajuanByFakultas();
                } elseif ($action === 'statistik') {
                    $controller->getStatistik();
                } elseif ($action === 'mahasiswa') {
                    $controller->getMahasiswa();
                } elseif ($action === 'dosen') {
                    $controller->getDosenPembimbing();
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
            }
            break;

        case 'admin-sekolah':
            require_once 'controllers/AdminSekolahController.php';
            $controller = new AdminSekolahController();
            
            if ($method === 'GET') {
                if ($action === 'profil') {
                    $controller->getProfil();
                } elseif ($action === 'pengajuan') {
                    $controller->getPengajuanBySekolah();
                } elseif ($action === 'statistik') {
                    $controller->getStatistik();
                } elseif ($action === 'siswa') {
                    $controller->getSiswa();
                } elseif ($action === 'guru') {
                    $controller->getGuruPembimbing();
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
            }
            break;

        case 'dashboard':
            require_once 'controllers/DashboardController.php';
            $controller = new DashboardController(); // No argument needed
            
            if ($method === 'GET') {
                if ($endpoint === 'dashboard' && $action === 'admin' && $id === 'stats') {
                     // GET /dashboard/admin/stats
                     $controller->getAdminStats();
                } else {
                    jsonResponse(['success' => false, 'message' => 'Endpoint tidak ditemukan'], 404);
                }
            } else {
                 jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
            }
            break;

        default:
            jsonResponse([
                'success' => true,
                'message' => 'API MagangKu UMPAR - v1.0',
                'endpoints' => [
                    'auth' => '/api/auth/{login|register|logout|profil}',
                    'pengajuan' => '/api/pengajuan',
                    'laporan' => '/api/laporan',
                    'nilai' => '/api/nilai/{pengajuan_id}',
                    'notifikasi' => '/api/notifikasi',
                    'kehadiran' => '/api/kehadiran/{pengajuan_id}',
                    'bimbingan' => '/api/bimbingan',
                    'admin-fakultas' => '/api/admin-fakultas/{profil|pengajuan|statistik|mahasiswa|dosen}',
                    'admin-sekolah' => '/api/admin-sekolah/{profil|pengajuan|statistik|siswa|guru}',
                ]
            ]);
    }
} catch (Exception $e) {
    jsonResponse([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ], 500);
}
