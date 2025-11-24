import 'package:latlong2/latlong.dart';

class DistrictPolygons {
  static final Map<String, List<LatLng>> polygons = {
    // 1) Алматы ауданы – орталық-шығыс бөлігі, шағын көпбұрыш
    'Алматы ауданы': [
      // Шығыс-оңтүстік шығыс бөлігі (қызыл контурға жақын)
      LatLng(51.2050, 71.5000),
      LatLng(51.2150, 71.5600),
      LatLng(51.1950, 71.6300),
      LatLng(51.1550, 71.6400),
      LatLng(51.1250, 71.6000),
      LatLng(51.1300, 71.5400),
      LatLng(51.1450, 71.4800),
      LatLng(51.1750, 71.4600),
    ],
    // 2) Байқоңыр ауданы – солтүстік-орталық
    'Байқоныр ауданы': [
      LatLng(51.2460, 71.3600),
      LatLng(51.2600, 71.4000),
      LatLng(51.2570, 71.4800),
      LatLng(51.2280, 71.5000),
      LatLng(51.2180, 71.4400),
      LatLng(51.2250, 71.3800),
    ],
    // 3) Есіл ауданы – оңтүстік орталық/оңтүстік-шығыс
    'Есіл ауданы': [
      LatLng(51.1820, 71.3600),
      LatLng(51.1960, 71.4000),
      LatLng(51.1880, 71.4600),
      LatLng(51.1500, 71.4650),
      LatLng(51.1220, 71.4300),
      LatLng(51.1350, 71.3800),
    ],
    // 4) Нұра ауданы – батыс/оңтүстік-батыс
    'Нұра ауданы': [
      LatLng(51.2150, 71.2600),
      LatLng(51.2200, 71.3400),
      LatLng(51.1900, 71.3600),
      LatLng(51.1550, 71.3400),
      LatLng(51.1300, 71.2900),
      LatLng(51.1400, 71.2300),
    ],
    // 5) Сарайшық ауданы – оңтүстік-шығыс/шығыс
    'Сарайшық ауданы': [
      LatLng(51.1680, 71.4700),
      LatLng(51.1850, 71.5050),
      LatLng(51.1700, 71.5600),
      LatLng(51.1300, 71.5600),
      LatLng(51.1250, 71.5000),
      LatLng(51.1450, 71.4600),
    ],
    // 6) Сарыарқа ауданы – солтүстік-батыс
    'Сарыарқа ауданы': [
      LatLng(51.2550, 71.3000),
      LatLng(51.2650, 71.3600),
      LatLng(51.2450, 71.3800),
      LatLng(51.2250, 71.3600),
      LatLng(51.2200, 71.3000),
      LatLng(51.2350, 71.2700),
    ],
  };

  static LatLng? getCenter(String district) {
    final poly = polygons[district];
    if (poly == null || poly.isEmpty) return null;
    double lat = 0;
    double lng = 0;
    for (final p in poly) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / poly.length, lng / poly.length);
  }
}
