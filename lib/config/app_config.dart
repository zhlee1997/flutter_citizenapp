class AppConfig {
  // IBS Google Map API Key
  String get googleMapApiKey => 'AIzaSyBQmKCI94m7awSBd_x4c-CFAnnsprCJ45w';

  bool isProductionInternal = false;
  bool isUsingLinkingVision = true;

  static String baseURL = '';
  String get baseUrlProduction => isProductionInternal
      ? "http://10.16.24.130:28300/mobile/api/"
      : "https://citizen.sioc.sma.gov.my/mobile/api/"; // Staging Env
  String get baseUrlStaging =>
      'http://10.16.24.139:28300/mobile/api/'; // Staging Env
  String get baseUrlDev => 'http://124.70.29.113:28300/mobile/api/'; // Dev Env
  String get baseUrlTest =>
      'http://120.46.210.99:28300/mobile/api/'; // Test Env

  static Flavor picFlavor = Flavor.dev; // default
  String get picBaseUrlProduction =>
      'https://pic.sioc.sma.gov.my'; // Staging Env
  String get picBaseUrlStaging => 'http://10.16.24.139:9000'; // Staging Env
  String get picBaseUrlDev => 'http://124.70.29.113:9000'; // Dev Env
  String get picBaseUrlTest => 'http://120.46.210.99:9000'; // Test Env

  static String sarawakIdCallbackURL = ''; // default
  String get sarawakIdCallbackURLProduction =>
      'https://citizen.sioc.sma.gov.my/'; // Production Env
  String get sarawakIdCallbackURLStaging =>
      'http://10.16.24.139:28300/'; // Staging Env
  String get sarawakIdCallbackURLDev =>
      'http://124.70.29.113:28300/'; // Dev Env
  String get sarawakIdCallbackURLTest =>
      'http://120.46.210.99:28300/'; // Test Env

  static String sarawakIdClientID = ''; // default
  String get sarawakIdClientIDProduction =>
      'citizenapp_mobile_production'; // Production Env
  String get sarawakIdClientIDStaging =>
      'citizenapp_mobile_staging'; // Staging Env
  String get sarawakIdClientIDDev => 'citizenapp_mobile_dev'; // Dev Env
  String get sarawakIdClientIDTest => 'citizenapp_mobile_ut'; // Test Env
}

enum Flavor {
  dev,
  test,
  staging,
  prod,
}
