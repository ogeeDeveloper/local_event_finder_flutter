class Event {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String? organizerLogoUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final Location? location;
  final bool isOnline;
  final String? joinUrl;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final String currency;
  final String category;
  final List<String> tags;
  final int attendees;
  final bool isSoldOut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    this.organizerLogoUrl,
    required this.startDate,
    this.endDate,
    this.location,
    this.isOnline = false,
    this.joinUrl,
    this.imageUrl,
    this.price = 0.0,
    this.originalPrice,
    this.currency = "USD",
    required this.category,
    this.tags = const [],
    this.attendees = 0,
    this.isSoldOut = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizer: json['organizer'] ?? '',
      organizerLogoUrl: json['organizerLogoUrl'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      isOnline: json['isOnline'] ?? false,
      joinUrl: json['joinUrl'],
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice:
          json['originalPrice'] != null ? json['originalPrice'].toDouble() : null,
      currency: json['currency'] ?? 'USD',
      category: json['category'] ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      attendees: json['attendees'] ?? 0,
      isSoldOut: json['isSoldOut'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'organizerLogoUrl': organizerLogoUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location?.toJson(),
      'isOnline': isOnline,
      'joinUrl': joinUrl,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'category': category,
      'tags': tags,
      'attendees': attendees,
      'isSoldOut': isSoldOut,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Sample events for testing
  static List<Event> getSampleEvents() {
    return [
      Event(
        id: '1',
        title: 'Music Festival 2025',
        description: 'A three-day music festival featuring top artists from around the world.',
        organizer: 'EventPro',
        organizerLogoUrl: 'https://example.com/eventpro.png',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        location: Location(
          name: 'Central Park',
          address: '123 Park Avenue, New York, NY',
          latitude: 40.7812,
          longitude: -73.9665,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3',
        price: 150.0,
        category: 'Music',
        tags: ['music', 'festival', 'outdoor'],
        attendees: 1200,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Event(
        id: '2',
        title: 'Tech Conference 2025',
        description: 'Learn about the latest technologies and network with industry professionals.',
        organizer: 'TechCorp',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 17)),
        location: Location(
          name: 'Convention Center',
          address: '456 Tech Blvd, San Francisco, CA',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
        price: 299.0,
        category: 'Technology',
        tags: ['tech', 'conference', 'networking'],
        attendees: 800,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Event(
        id: '3',
        title: 'Food & Wine Festival',
        description: 'Taste exquisite dishes and wines from top chefs and wineries.',
        organizer: 'Culinary Arts Association',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        location: Location(
          name: 'Riverfront Park',
          address: '789 River Road, Chicago, IL',
          latitude: 41.8781,
          longitude: -87.6298,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        price: 75.0,
        category: 'Food & Drink',
        tags: ['food', 'wine', 'festival'],
        attendees: 500,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Event(
        id: '4',
        title: 'Yoga Retreat',
        description: 'A weekend of relaxation, meditation, and yoga practices.',
        organizer: 'Wellness Center',
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 22)),
        location: Location(
          name: 'Mountain View Resort',
          address: '101 Mountain Road, Boulder, CO',
          latitude: 40.0150,
          longitude: -105.2705,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597',
        price: 350.0,
        category: 'Health & Wellness',
        tags: ['yoga', 'wellness', 'retreat'],
        attendees: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Event(
        id: '5',
        title: 'Art Exhibition',
        description: 'Featuring works from emerging local artists.',
        organizer: 'City Art Gallery',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        location: Location(
          name: 'Downtown Art Gallery',
          address: '222 Art Street, Seattle, WA',
          latitude: 47.6062,
          longitude: -122.3321,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1531058020387-3be344556be6',
        price: 15.0,
        category: 'Art',
        tags: ['art', 'exhibition', 'culture'],
        attendees: 300,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}

class Location {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
