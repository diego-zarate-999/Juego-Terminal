import 'dart:typed_data';
import '../../utils/utils.dart';

/// Parámetros de una app EMV (AID) candidata para selección.
class EmvCandidateApp {
  Uint8List aid;
  int priority;
  String appName;

  EmvCandidateApp({
    required Uint8List aid,
    required this.priority,
    required String appName,
  })  : aid = assertVarLen(
          aid,
          "AID",
          minLen: 5,
          maxLen: 16,
        ),
        appName = assertVarLen(
          appName,
          "appName",
          minLen: 1,
          maxLen: 16,
        );

  factory EmvCandidateApp.fromJson(Map<String, dynamic> jsonData) {
    return EmvCandidateApp(
      aid: jsonData['aid'],
      priority: jsonData['priority'],
      appName: jsonData['appName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': aid,
      'priority': priority,
      'appName': appName,
    };
  }
}
