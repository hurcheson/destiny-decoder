class AppConfig {
  /// Change this when switching environments
  /// Production: https://destiny-decoder-production.up.railway.app (Railway)
  /// Development: http://10.0.2.2:8000 (emulator) or http://<your-ip>:8000 (physical device)
  /// To override, use: flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://destiny-decoder-production.up.railway.app',
  );

  /// Optional public landing URL for sharing (e.g. website or store link)
  /// Provide via: --dart-define=APP_SHARE_URL=https://your-landing.page
  /// If empty, share messages will omit direct links.
  /// For testing deep links, use: destinydecoder://destinydecoder.app
  static const String appShareUrl = String.fromEnvironment(
    'APP_SHARE_URL',
    defaultValue: 'destinydecoder://destinydecoder.app',
  );
}

