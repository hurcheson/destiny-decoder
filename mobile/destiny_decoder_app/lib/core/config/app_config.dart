class AppConfig {
  /// Change this when switching environments
  /// Android Physical Device: Use your PC's IP address
  /// Windows Desktop: Use http://localhost:8001
  /// Android Emulator: Use http://10.0.2.2:8001
  /// iOS Simulator: Use http://localhost:8001
  /// Prefer setting via --dart-define to match your LAN IP:
  /// flutter run --dart-define=API_BASE_URL=http://<your-ip>:8001
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.197:8001',
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

