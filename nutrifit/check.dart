import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

void main() {
  for (var value in HealthDataType.values) {
    if (value.name.contains('MINUTE') || value.name.contains('TIME') || value.name.contains('MOVE') || value.name.contains('EXERCISE')) {
      debugPrint(value.name);
    }
  }
}
