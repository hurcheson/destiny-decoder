/// Android-specific configuration for Destiny Decoder
///
/// This file contains configuration settings specific to Android platform,
/// including Google Play Billing setup and backend URLs.

class AndroidConfig {
  /// Backend API base URL
  /// IMPORTANT: Update this when deploying to production
  /// Development: http://10.0.2.2:8000 (emulator to host machine)
  /// Production: https://api.destinydecoderapp.com
  static const String backendBaseUrl = 'http://10.0.2.2:8000';

  /// Google Play Store package name
  static const String googlePlayPackageName = 'com.example.destiny_decoder_app';

  /// Google Play subscription product SKUs
  /// These must match the SKUs created in Google Play Console
  static const String premiumMonthlySku = 'destiny_decoder_premium_monthly';
  static const String premiumAnnualSku = 'destiny_decoder_premium_annual';
  static const String proAnnualSku = 'destiny_decoder_pro_annual';

  /// List of all available subscription SKUs
  static const List<String> subscriptionSkus = [
    premiumMonthlySku,
    premiumAnnualSku,
    proAnnualSku,
  ];

  /// Google Play Billing configuration
  static const int billingClientVersion = 7; // Google Play Billing Library 7.0.0

  /// Request code for billing activities
  static const int billingRequestCode = 1001;

  /// Timeouts (in seconds)
  static const int networkTimeoutSeconds = 30;
  static const int receiptValidationTimeoutSeconds = 60;

  /// Whether to use sandbox testing
  /// Set to false for production
  static const bool useSandboxTesting = true;

  /// Enable debug logging
  static const bool debugLogging = true;

  /// Paths for storing local data
  static const String preferencesKeyPrefix = 'destiny_decoder_';
  static const String subscriptionStatusKey = '${preferencesKeyPrefix}subscription_status';
  static const String lastReceiptKey = '${preferencesKeyPrefix}last_receipt';
  static const String lastReceiptTimeKey = '${preferencesKeyPrefix}last_receipt_time';

  /// Feature flags
  static const bool enablePaywall = true;
  static const bool enableSubscriptions = true;
  static const bool enablePremiumFeatures = true;

  /// Logging helper
  static void log(String tag, String message) {
    if (debugLogging) {
      print('[$tag] $message');
    }
  }

  /// Validate that required config is set up
  static void validateConfig() {
    assert(
      googlePlayPackageName.isNotEmpty,
      'Google Play package name must be set',
    );
    assert(
      subscriptionSkus.isNotEmpty,
      'At least one subscription SKU must be defined',
    );
  }
}

/// Environment configuration for backend
class EnvironmentConfig {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  /// Current environment
  static const String currentEnvironment = production;

  /// Get backend URL based on environment
  static String getBackendUrl() {
    switch (currentEnvironment) {
      case development:
        return 'http://10.0.2.2:8000'; // Emulator to host
      case staging:
        return 'https://staging-api.destinydecoderapp.com';
      case production:
        return 'https://destiny-decoder-production.up.railway.app';
      default:
        return 'http://10.0.2.2:8000';
    }
  }

  /// Get whether sandbox testing should be enabled
  static bool shouldUseSandbox() {
    return currentEnvironment == development || currentEnvironment == staging;
  }

  /// Get whether debug logging is enabled
  static bool isDebugEnabled() {
    return currentEnvironment == development;
  }
}
