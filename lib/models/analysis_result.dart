import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'analysis_result.g.dart';

@HiveType(typeId: 0)
class AnalysisResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String findings;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final String recommendation;

  @HiveField(5)
  final DateTime dateTime;

  @HiveField(6)
  final Map<String, dynamic> rawResponse;

  AnalysisResult({
    String? id,
    required this.imagePath,
    required this.findings,
    required this.summary,
    required this.recommendation,
    DateTime? dateTime,
    required this.rawResponse,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.dateTime = dateTime ?? DateTime.now();

  factory AnalysisResult.fromJson(Map<String, dynamic> json, String imagePath) {
    return AnalysisResult(
      imagePath: imagePath,
      findings: json['findings'] ?? '',
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'] ?? '',
      rawResponse: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'findings': findings,
      'summary': summary,
      'recommendation': recommendation,
      'dateTime': dateTime.toIso8601String(),
      'rawResponse': rawResponse,
    };
  }
}