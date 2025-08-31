class DrinkSummary {
  final String id;
  final String name;
  final String thumb;

  const DrinkSummary({
    required this.id,
    required this.name,
    required this.thumb,
  });

  factory DrinkSummary.fromJson(Map<String, dynamic> j) => DrinkSummary(
    id: j['idDrink'] as String,
    name: j['strDrink'] as String,
    thumb: j['strDrinkThumb'] as String,
  );
}
