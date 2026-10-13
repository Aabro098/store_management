enum Flavor { dev, staging, prod }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
  });

  static FlavorConfig? _instance;

  final Flavor flavor;
  final String appName;
  final String baseUrl;

  static FlavorConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('FlavorConfig has not been initialized.');
    }
    return config;
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String baseUrl,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      baseUrl: baseUrl,
    );
  }
}
