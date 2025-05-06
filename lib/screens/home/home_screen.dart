import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToEvents;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToCreateEvent;
  final Function(String) onNavigateToEventDetails;

  const HomeScreen({
    Key? key,
    required this.onNavigateToSearch,
    required this.onNavigateToEvents,
    required this.onNavigateToProfile,
    required this.onNavigateToCreateEvent,
    required this.onNavigateToEventDetails,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  List<Event> _featuredEvents = [];
  List<Event> _nearbyEvents = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final user = await _authService.getCurrentUser();
      
      // Get featured events
      final featuredEvents = await _eventService.simulateGetFeaturedEvents();
      
      // Get nearby events
      final nearbyEvents = await _eventService.simulateGetNearbyEvents();
      
      // Get categories
      final categories = await _eventService.simulateGetCategories();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _featuredEvents = featuredEvents;
          _nearbyEvents = nearbyEvents;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) {
      // Deselect category
      setState(() {
        _selectedCategoryId = null;
      });
      
      // Reload all events
      _loadData();
    } else {
      setState(() {
        _selectedCategoryId = categoryId;
        _isLoading = true;
      });
      
      try {
        // Filter events by category
        final events = await _eventService.simulateGetEvents(categoryId: categoryId);
        
        if (mounted) {
          setState(() {
            _featuredEvents = events.take(3).toList();
            _nearbyEvents = events.skip(3).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null && _featuredEvents.isEmpty && _nearbyEvents.isEmpty
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting and profile
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Category filters
            _buildCategoryFilters(),
            
            const SizedBox(height: 24),
            
            // Featured events section
            _buildFeaturedEventsSection(),
            
            const SizedBox(height: 24),
            
            // Nearby events section
            _buildNearbyEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String greeting = _getGreeting();
    final String userName = _currentUser?.fullName.split(' ').first ?? 'Guest';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textColor03,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          GestureDetector(
            onTap: widget.onNavigateToProfile,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryContainerLight,
              backgroundImage: _currentUser?.profileImageUrl != null
                  ? NetworkImage(_currentUser!.profileImageUrl!)
                  : null,
              child: _currentUser?.profileImageUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1, // +1 for "All" category
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" category
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                name: 'All',
                isSelected: _selectedCategoryId == null,
                onTap: () => _selectCategory(null),
              ),
            );
          } else {
            final category = _categories[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                name: category.name,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => _selectCategory(category.id),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeaturedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: widget.onNavigateToEvents,
                child: Text(
                  'See All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featuredEvents.length,
            itemBuilder: (context, index) {
              final event = _featuredEvents[index];
              return SizedBox(
                width: 280,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: EventCard(
                    event: event,
                    onTap: () => widget.onNavigateToEventDetails(event.id),
                    isFeatured: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: widget.onNavigateToEvents,
                child: Text(
                  'See All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _nearbyEvents.length,
          itemBuilder: (context, index) {
            final event = _nearbyEvents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(
                event: event,
                onTap: () => widget.onNavigateToEventDetails(event.id),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.textColor04,
            width: 1,
          ),
        ),
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textColor02,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
