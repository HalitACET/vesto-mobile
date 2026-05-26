// lib/core/utils/mannequin_utils.dart
//
// Mannequin asset yolu ve slot pozisyonlarını döndüren yardımcı fonksiyonlar.
// Aynı mantık outfit_providers.dart'taki mannequinTypeProvider'da da var;
// bu dosya UI katmanı için saf fonksiyon olarak sunar.

/// Kullanıcının cinsiyetine göre mannequin SVG asset yolunu döndürür.
/// gender: 'female' | 'male' | null/other → unisex
String getMannequinAsset(String? gender) {
  switch (gender) {
    case 'female':
      return 'assets/mannequin/female.svg';
    case 'male':
      return 'assets/mannequin/male.svg';
    default:
      return 'assets/mannequin/unisex.svg';
  }
}

/// Canvas boyutları (300×540 veya herhangi bir dinamik boyut) üzerindeki anatomik slot pozisyonları.
/// Web'deki 400×720 referansıyla orantılı hesaplanmıştır.
///
/// Slot → top%, left%, width%, height% (canvas yüzdesi)
const Map<String, SlotBounds> kSlotBounds = {
  'accessory': SlotBounds(top: 10 / 720, left: 0.25, width: 0.50, height: 110 / 720),
  'top':       SlotBounds(top: 120 / 720, left: 0.15, width: 0.70, height: 210 / 720),
  'bottom':    SlotBounds(top: 330 / 720, left: 0.175, width: 0.65, height: 210 / 720),
  'shoes':     SlotBounds(top: 548 / 720, left: 0.20, width: 0.60, height: 140 / 720),
};

/// Slot sınırlarını yüzde olarak tutan değer nesnesi.
class SlotBounds {
  const SlotBounds({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  final double top;
  final double left;
  final double width;
  final double height;

  /// Canvas'ın [canvasWidth] ve [canvasHeight] boyutlarına göre
  /// piksel değerlerini döndürür.
  ({double top, double left, double width, double height}) toPixels({
    required double canvasWidth,
    required double canvasHeight,
  }) {
    return (
      top: top * canvasHeight,
      left: left * canvasWidth,
      width: width * canvasWidth,
      height: height * canvasHeight,
    );
  }
}
