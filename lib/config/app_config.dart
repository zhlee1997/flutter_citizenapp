class AppConfig {
  // IBS Google Map API Key
  String get googleMapApiKey => 'AIzaSyBQmKCI94m7awSBd_x4c-CFAnnsprCJ45w';

  static String baseURL = '';
  String get baseUrlDev => 'http://124.70.29.113:28300/mobile/api/'; // Dev Env
  String get baseUrlTest =>
      'http://120.46.210.99:28300/mobile/api/'; // Test Env

  static Flavor picFlavor = Flavor.dev;
  String get picBaseUrlDev => 'http://124.70.29.113:9000'; // Dev Env
  String get picBaseUrlTest => 'http://120.46.210.99:9000'; // Dev Env
}

enum Flavor {
  dev,
  test,
  staging,
  prod,
}
