import 'package:flutter/foundation.dart';

const String _prodBase = "https://tazaqala-production.up.railway.app/api";

final String apiBaseUrl = const String.fromEnvironment(
  "API_BASE_URL",
  defaultValue: "",
).isNotEmpty
    ? const String.fromEnvironment("API_BASE_URL")
    : _prodBase;
