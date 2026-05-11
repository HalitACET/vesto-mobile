
enum WeatherTier { freezing, cold, cool, mild, hot }

class WeatherOutfitRule {
  final double minTemp;
  final double maxTemp;
  final List<String> topCategories;
  final List<String> bottomCategories;
  final List<String> outerwearCategories;
  final List<String> shoeCategories;
  final List<String> accessories;

  const WeatherOutfitRule({
    required this.minTemp,
    required this.maxTemp,
    required this.topCategories,
    required this.bottomCategories,
    this.outerwearCategories = const [],
    required this.shoeCategories,
    this.accessories = const [],
  });
}

const Map<WeatherTier, WeatherOutfitRule> weatherOutfitRules = {
  WeatherTier.hot: WeatherOutfitRule(
    minTemp: 25,
    maxTemp: 100,
    topCategories: ['tshirt', 'shirt', 'tank_top'],
    bottomCategories: ['shorts', 'skirt'],
    outerwearCategories: [],
    shoeCategories: ['sneakers', 'sandals'],
    accessories: ['hat', 'sunglasses'],
  ),
  WeatherTier.mild: WeatherOutfitRule(
    minTemp: 18,
    maxTemp: 25,
    topCategories: ['shirt', 'tshirt', 'blouse'],
    bottomCategories: ['trousers', 'skirt', 'jeans'],
    outerwearCategories: ['cardigan', 'blazer'],
    shoeCategories: ['sneakers', 'flats'],
  ),
  WeatherTier.cool: WeatherOutfitRule(
    minTemp: 10,
    maxTemp: 18,
    topCategories: ['hoodie', 'sweater', 'tshirt'],
    bottomCategories: ['trousers', 'jeans'],
    outerwearCategories: ['jacket', 'cardigan', 'vest'],
    shoeCategories: ['sneakers', 'boots'],
    accessories: ['scarf'],
  ),
  WeatherTier.cold: WeatherOutfitRule(
    minTemp: 0,
    maxTemp: 10,
    topCategories: ['sweater', 'hoodie'],
    bottomCategories: ['trousers', 'jeans'],
    outerwearCategories: ['coat', 'jacket'],
    shoeCategories: ['boots'],
    accessories: ['scarf', 'gloves'],
  ),
  WeatherTier.freezing: WeatherOutfitRule(
    minTemp: -100,
    maxTemp: 0,
    topCategories: ['sweater'],
    bottomCategories: ['trousers', 'jeans'],
    outerwearCategories: ['coat'],
    shoeCategories: ['boots'],
    accessories: ['scarf', 'gloves', 'hat'],
  ),
};
