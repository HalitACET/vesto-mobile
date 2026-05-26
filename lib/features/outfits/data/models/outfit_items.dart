import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_items.freezed.dart';
part 'outfit_items.g.dart';

@freezed
abstract class OutfitItems with _$OutfitItems {
  const factory OutfitItems({
    String? topId,
    String? bottomId,
    String? shoesId,
    String? accessoryId,
  }) = _OutfitItems;

  factory OutfitItems.fromJson(Map<String, dynamic> json) => _$OutfitItemsFromJson(json);
}

extension OutfitItemsX on OutfitItems {
  bool get isEmpty => topId == null && bottomId == null && shoesId == null && accessoryId == null;
  
  List<String> get allItemIds => [
    ?topId,
    ?bottomId,
    ?shoesId,
    ?accessoryId,
  ];
}
