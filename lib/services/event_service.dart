import 'dart:io';
import '../models/event.dart';
import '../models/category.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService = ApiService();
  
  // Singleton pattern
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  Future<List<Event>> getEvents({int? categoryId}) async {
    try {
      String endpoint = '/events';
      if (categoryId != null) {
        endpoint += '?categoryId=$categoryId';
      }
      
      final response = await _apiService.get(endpoint);
      final List<dynamic> eventsJson = response['events'];
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load events: ${e.toString()}');
    }
  }

  Future<List<Event>> getFeaturedEvents() async {
    try {
      final response = await _apiService.get('/events/featured');
      final List<dynamic> eventsJson = response['events'];
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load featured events: ${e.toString()}');
    }
  }

  Future<List<Event>> getNearbyEvents({double? latitude, double? longitude, double? radius}) async {
    try {
      String endpoint = '/events/nearby';
      
      if (latitude != null && longitude != null) {
        endpoint += '?latitude=$latitude&longitude=$longitude';
        
        if (radius != null) {
          endpoint += '&radius=$radius';
        }
      }
      
      final response = await _apiService.get(endpoint);
      final List<dynamic> eventsJson = response['events'];
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load nearby events: ${e.toString()}');
    }
  }

  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _apiService.get('/events/$eventId');
      return Event.fromJson(response['event']);
    } catch (e) {
      throw Exception('Failed to load event: ${e.toString()}');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      final List<dynamic> categoriesJson = response['categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: ${e.toString()}');
    }
  }

  Future<Event> createEvent({
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    DateTime? endDate,
    required String location,
    required double latitude,
    required double longitude,
    double? price,
    bool isFreeEvent = false,
    int? capacity,
    bool isPrivateEvent = false,
    File? imageFile,
  }) async {
    try {
      // In a real app, you would first upload the image to a server
      // and get back a URL to include in the event data
      String? imageUrl;
      if (imageFile != null) {
        // This would be replaced with actual image upload code
        imageUrl = await _simulateImageUpload(imageFile);
      }
      
      final data = {
        'title': title,
        'description': description,
        'category': category,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'location': {
          'name': location,
          'address': location,
          'latitude': latitude,
          'longitude': longitude,
        },
        'price': isFreeEvent ? 0.0 : (price ?? 0.0),
        'capacity': capacity,
        'isPrivateEvent': isPrivateEvent,
        'imageUrl': imageUrl,
      };

      final response = await _apiService.post('/events', data);
      return Event.fromJson(response['event']);
    } catch (e) {
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  // Simulate image upload for demo purposes
  Future<String> _simulateImageUpload(File imageFile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return a mock image URL
    return 'https://example.com/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  // For demo purposes, simulate getting events without a backend
  Future<List<Event>> simulateGetEvents({int? categoryId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final allEvents = Event.getSampleEvents();
    
    if (categoryId != null) {
      // Filter events by category
      final categories = Category.getSampleCategories();
      final categoryName = categories.firstWhere((c) => c.id == categoryId).name;
      return allEvents.where((event) => event.category == categoryName).toList();
    }
    
    return allEvents;
  }

  // For demo purposes, simulate getting featured events without a backend
  Future<List<Event>> simulateGetFeaturedEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return the first 3 sample events as featured
    return Event.getSampleEvents().take(3).toList();
  }

  // For demo purposes, simulate getting nearby events without a backend
  Future<List<Event>> simulateGetNearbyEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return the last 3 sample events as nearby
    return Event.getSampleEvents().reversed.take(3).toList();
  }

  // For demo purposes, simulate getting categories without a backend
  Future<List<Category>> simulateGetCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return Category.getSampleCategories();
  }

  // For demo purposes, simulate creating an event without a backend
  Future<Event> simulateCreateEvent({
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    DateTime? endDate,
    required String location,
    required double latitude,
    required double longitude,
    double? price,
    bool isFreeEvent = false,
    int? capacity,
    bool isPrivateEvent = false,
    File? imageFile,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Create a new event with the provided data
    return Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      organizer: 'Current User',
      startDate: startDate,
      endDate: endDate,
      location: Location(
        name: location,
        address: location,
        latitude: latitude,
        longitude: longitude,
      ),
      price: isFreeEvent ? 0.0 : (price ?? 0.0),
      category: category,
      imageUrl: imageFile != null ? 'https://example.com/images/${DateTime.now().millisecondsSinceEpoch}.jpg' : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
