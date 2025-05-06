import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/booking/payment_method_screen.dart';
import 'screens/events/booking/payment_confirmation_screen.dart';
import 'screens/home/home_screen.dart';
import 'models/event.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Event Finder',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() async {
    await _authService.logout();
    
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      return MainNavigator(onLogout: _handleLogout);
    } else {
      return AuthNavigator(onLoginSuccess: _handleLoginSuccess);
    }
  }
}

class AuthNavigator extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthNavigator({
    Key? key,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool _showLogin = true;

  void _toggleAuthScreen() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(
        onLoginSuccess: widget.onLoginSuccess,
        onSignUpClick: _toggleAuthScreen,
        onForgotPasswordClick: () {
          // Handle forgot password
        },
      );
    } else {
      return SignupScreen(
        onSignupSuccess: widget.onLoginSuccess,
        onLoginClick: _toggleAuthScreen,
      );
    }
  }
}

class MainNavigator extends StatefulWidget {
  final VoidCallback onLogout;

  const MainNavigator({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          onNavigateBack: () => Navigator.pop(context),
          onEventCreated: () {
            Navigator.pop(context);
            _navigateToPage(0); // Navigate to home after event creation
          },
        ),
      ),
    );
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          eventId: eventId,
          onNavigateBack: () => Navigator.pop(context),
          onBookEvent: (event) => _navigateToPaymentMethod(event),
        ),
      ),
    );
  }

  void _navigateToPaymentMethod(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          event: event,
          onNavigateBack: () => Navigator.pop(context),
          onProceedToConfirmation: (event, quantity, paymentMethod) {
            _navigateToPaymentConfirmation(event, quantity, paymentMethod);
          },
        ),
      ),
    );
  }

  void _navigateToPaymentConfirmation(Event event, int quantity, String paymentMethod) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationScreen(
          event: event,
          quantity: quantity,
          paymentMethod: paymentMethod,
          onNavigateBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(
            onNavigateToSearch: () => _navigateToPage(1),
            onNavigateToEvents: () => _navigateToPage(2),
            onNavigateToProfile: () => _navigateToPage(3),
            onNavigateToCreateEvent: _navigateToCreateEvent,
            onNavigateToEventDetails: _navigateToEventDetails,
          ),
          // Placeholder screens for other tabs
          const Center(child: Text('Search Screen')),
          const Center(child: Text('Events Screen')),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Profile Screen'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onLogout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Create Event tab
            _navigateToCreateEvent();
          } else {
            _navigateToPage(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
