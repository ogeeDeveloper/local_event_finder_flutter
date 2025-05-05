import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    
    return null;
  }

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    final user = await getCurrentUser();
    return token != null && user != null;
  }

  Future<User> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('/auth/login', data, requiresAuth: false);
      
      // Save auth token
      await _apiService.saveAuthToken(response['token']);
      
      // Save user data
      final user = User.fromJson(response['user']);
      await saveCurrentUser(user);
      
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(String fullName, String email, String password, String? phoneNumber) async {
    try {
      final data = {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      };

      final response = await _apiService.post('/auth/register', data, requiresAuth: false);
      
      // Save auth token
      await _apiService.saveAuthToken(response['token']);
      
      // Save user data
      final user = User.fromJson(response['user']);
      await saveCurrentUser(user);
      
      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      // Even if the logout API call fails, we still want to clear local data
      print('Logout API call failed: ${e.toString()}');
    } finally {
      // Clear local data
      await _apiService.clearAuthToken();
      await clearCurrentUser();
    }
  }

  // For demo purposes, simulate login without a backend
  Future<User> simulateLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    // Create a mock user
    final user = User(
      id: '12345',
      fullName: email.split('@')[0],
      email: email,
      phoneNumber: '+1234567890',
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save mock auth token
    await _apiService.saveAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
    
    // Save user data
    await saveCurrentUser(user);
    
    return user;
  }

  // For demo purposes, simulate registration without a backend
  Future<User> simulateRegister(String fullName, String email, String password, String? phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Full name, email, and password are required');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    // Create a mock user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save mock auth token
    await _apiService.saveAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
    
    // Save user data
    await saveCurrentUser(user);
    
    return user;
  }
}
