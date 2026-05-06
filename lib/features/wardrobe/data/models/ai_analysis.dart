import 'package:equatable/equatable.dart';

/// Kıyafet üzerindeki AI tarafından tespit edilen renk bilgisi.
class DominantColor extends Equatable {
  const DominantColor({
    required this.hex,
    required this.percentage,
  });

  final String hex;
  final double percentage;

  factory DominantColor.fromMap(Map<String, dynamic> map) => DominantColor(
        hex: map['hex'] as String? ?? '#000000',
        percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        'hex': hex,
        'percentage': percentage,
      };

  @override
  List<Object?> get props => [hex, percentage];
}

/// AI tarafından tespit edilen desen türü.
enum AiPattern {
  solid('solid'),
  striped('striped'),
  plaid('plaid'),
  floral('floral'),
  graphic('graphic'),
  other('other');

  const AiPattern(this.value);
  final String value;

  static AiPattern fromString(String? value) => AiPattern.values.firstWhere(
        (p) => p.value == value,
        orElse: () => AiPattern.other,
      );
}

/// Hafta 6'da Cloud Function ile doldurulacak AI analiz modeli.
/// Şu an Firestore'dan okunabilir (web tarafı yazmış olabilir) ama
/// mobile yazma yapmaz — aiAnalysis: null olarak bırakılır.
class AiAnalysis extends Equatable {
  const AiAnalysis({
    required this.dominantColors,
    required this.pattern,
    required this.confidence,
    required this.analyzedAt,
    required this.modelVersion,
    this.detectedMaterial,
  });

  final List<DominantColor> dominantColors;
  final String? detectedMaterial;
  final AiPattern pattern;
  final double confidence;
  final DateTime analyzedAt;
  final String modelVersion;

  factory AiAnalysis.fromMap(Map<String, dynamic> map) {
    final colorsRaw = map['dominantColors'] as List<dynamic>?;
    return AiAnalysis(
      dominantColors: colorsRaw
              ?.map((e) =>
                  DominantColor.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      detectedMaterial: map['detectedMaterial'] as String?,
      pattern: AiPattern.fromString(map['pattern'] as String?),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      analyzedAt: map['analyzedAt'] != null
          ? (map['analyzedAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      modelVersion: map['modelVersion'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() => {
        'dominantColors': dominantColors.map((c) => c.toMap()).toList(),
        if (detectedMaterial != null) 'detectedMaterial': detectedMaterial,
        'pattern': pattern.value,
        'confidence': confidence,
        'analyzedAt': analyzedAt,
        'modelVersion': modelVersion,
      };

  @override
  List<Object?> get props => [
        dominantColors,
        detectedMaterial,
        pattern,
        confidence,
        analyzedAt,
        modelVersion,
      ];
}
