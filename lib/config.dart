class Environments {
  static const String PRODUCTION = 'prod';
  static const String QAS = 'QAS';
  static const String DEV = 'dev';
  static const String LOCAL = 'local';
}

class ConfigEnvironments {
  static const String _currentEnvironments = Environments.DEV; // Changed to DEV
  static final List<Map<String, String>> _availableEnvironments = [
    {'env': Environments.LOCAL, 'url': 'http://localhost:8080/api/'},
    {
      'env': Environments.DEV,
      'url': 'https://dev.upsen.id/api/', // Updated with your API
    },
    {'env': Environments.QAS, 'url': 'https://qa.upsen.id/api/'},
    {'env': Environments.PRODUCTION, 'url': 'https://upsen.id/api/'},
  ];

  static Map<String, String> getEnvironments() {
    return _availableEnvironments.firstWhere(
      (d) => d['env'] == _currentEnvironments,
    );
  }

  // Add attendance specific config
  static const double confidenceThreshold = 0.75;
  static const double autoProceedThreshold = 0.90;
  static const int maxRecognitionAttempts = 3;
  static const int syncIntervalMinutes = 5;
}
