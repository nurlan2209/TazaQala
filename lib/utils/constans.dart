import 'package:flutter/foundation.dart';

const String _mobileBase = "http://10.0.2.2:5001/api";
const String _webBase = "http://127.0.0.1:5001/api";

final String apiBaseUrl = const String.fromEnvironment(
  "API_BASE_URL",
  defaultValue: "",
).isNotEmpty
    ? const String.fromEnvironment("API_BASE_URL")
    : (kIsWeb ? _webBase : _mobileBase);

const List<String> astanaDistricts = [
  'Есіл ауданы',
  'Нұра ауданы',
  'Алматы ауданы',
  'Байқоныр ауданы',
  'Сарыарқа ауданы',
  'Сарайшық ауданы',
];

const Map<String, List<List<double>>> astanaDistrictPolygons = {
  'Есіл ауданы': [
    [51.121, 71.356],
    [51.164, 71.520],
    [51.225, 71.485],
    [51.210, 71.330],
  ],
  'Нұра ауданы': [
    [51.212, 71.010],
    [51.278, 71.200],
    [51.330, 71.060],
    [51.260, 70.930],
  ],
  'Алматы ауданы': [
    [51.110, 71.480],
    [51.085, 71.670],
    [51.165, 71.710],
    [51.185, 71.530],
  ],
  'Байқоныр ауданы': [
    [51.075, 71.310],
    [51.050, 71.450],
    [51.130, 71.460],
    [51.135, 71.300],
  ],
  'Сарыарқа ауданы': [
    [51.230, 71.450],
    [51.205, 71.650],
    [51.300, 71.710],
    [51.320, 71.520],
  ],
  'Сарайшық ауданы': [
    [51.165, 71.150],
    [51.140, 71.310],
    [51.230, 71.330],
    [51.250, 71.160],
  ],
};
