/// Environment Configuration
/// UMPAR Magang & PKL System
///
/// Konfigurasi environment untuk API URL

/// Environment modes
enum Environment {
  development,
  staging,
  production,
}

/// Configuration based on environment
class EnvironmentConfig {
  static Environment _current = Environment.development;

  /// Set current environment
  static void setEnvironment(Environment env) {
    _current = env;
  }

  /// Get current environment
  static Environment get current => _current;

  /// Check if development
  static bool get isDevelopment => _current == Environment.development;

  /// Check if production
  static bool get isProduction => _current == Environment.production;

  /// Get API base URL based on environment
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'http://localhost/umpar_magang_dan_pkl/api';
      case Environment.staging:
        return 'https://staging.magang.umpar.ac.id/api';
      case Environment.production:
        return 'https://magang.umpar.ac.id/api';
    }
  }

  /// Get timeout duration
  static Duration get timeout {
    switch (_current) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
        return const Duration(seconds: 30);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }

  /// Enable debug logging
  static bool get enableLogging {
    return _current != Environment.production;
  }

  /// Enable analytics
  static bool get enableAnalytics {
    return _current == Environment.production;
  }
}

/// Initialize environment from string (useful for build configs)
void initializeEnvironment(String env) {
  switch (env.toLowerCase()) {
    case 'production':
    case 'prod':
      EnvironmentConfig.setEnvironment(Environment.production);
      break;
    case 'staging':
    case 'stage':
      EnvironmentConfig.setEnvironment(Environment.staging);
      break;
    default:
      EnvironmentConfig.setEnvironment(Environment.development);
  }
}
