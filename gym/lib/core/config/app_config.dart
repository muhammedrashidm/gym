enum Flavor { dev, staging, prod }

class AppConfig {
  final Flavor flavor;
  final String baseUrl;
  final String appName;
  final bool enableLogging;

  const AppConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
    required this.enableLogging,
  });

  static const dev = AppConfig._(
    flavor: Flavor.dev,
    baseUrl: 'http://ec2-43-204-220-28.ap-south-1.compute.amazonaws.com/api/v1',
    appName: 'Kinetic (Dev)',
    enableLogging: true,
  );

  static const staging = AppConfig._(
    flavor: Flavor.staging,
    baseUrl: 'https://api.staging.kinetic.com/api/v1',
    appName: 'Kinetic (Staging)',
    enableLogging: true,
  );

  static const prod = AppConfig._(
    flavor: Flavor.prod,
    baseUrl: 'https://api.kinetic.com/api/v1',
    appName: 'Kinetic',
    enableLogging: false,
  );
}
