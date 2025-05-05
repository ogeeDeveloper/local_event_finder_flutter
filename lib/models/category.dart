class Category {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  // Sample categories for testing
  static List<Category> getSampleCategories() {
    return [
      Category(id: 1, name: 'Music', iconUrl: 'assets/icons/music.png'),
      Category(id: 2, name: 'Technology', iconUrl: 'assets/icons/technology.png'),
      Category(id: 3, name: 'Food & Drink', iconUrl: 'assets/icons/food.png'),
      Category(id: 4, name: 'Health & Wellness', iconUrl: 'assets/icons/wellness.png'),
      Category(id: 5, name: 'Art', iconUrl: 'assets/icons/art.png'),
      Category(id: 6, name: 'Business', iconUrl: 'assets/icons/business.png'),
      Category(id: 7, name: 'Sports', iconUrl: 'assets/icons/sports.png'),
      Category(id: 8, name: 'Education', iconUrl: 'assets/icons/education.png'),
    ];
  }
}
