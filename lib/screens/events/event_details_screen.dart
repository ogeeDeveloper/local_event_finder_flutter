import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final VoidCallback onNavigateBack;
  final Function(Event) onBookEvent;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
    required this.onNavigateBack,
    required this.onBookEvent,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? _event;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, this would fetch the event from the backend
      // For now, we'll simulate it with sample data
      final events = Event.getSampleEvents();
      final event = events.firstWhere(
        (e) => e.id == widget.eventId,
        orElse: () => throw Exception('Event not found'),
      );
      
      if (mounted) {
        setState(() {
          _event = event;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onNavigateBack,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _event != null
                  ? _buildEventDetails()
                  : const Center(
                      child: Text('Event not found'),
                    ),
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
            onPressed: _loadEventDetails,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    final event = _event!;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Stack(
            children: [
              // Event image
              SizedBox(
                height: 220,
                width: double.infinity,
                child: event.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.event,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              
              // Category badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.category,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              
              // Price badge
              Positioned(
                top: 16,
                right: 16,
                child: Text(
                  '\$${event.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Category
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                Text(
                  event.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryLight,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Date & Time
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(event.startDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(event.startDate) +
                          (event.endDate != null
                              ? ' - ${DateFormat('HH:mm').format(event.endDate!)}'
                              : ''),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 16),
                
                // Event Organizer
                Text(
                  'Event Organizer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // Organizer profile image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: event.organizerLogoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(event.organizerLogoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: event.organizerLogoUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: Text(
                        event.organizer,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        // Chat with organizer functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat functionality not implemented yet'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Chat'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Location
                if (event.location != null) ...[
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location!.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Map placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.map,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Map view',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          Text(
                            'Lat: ${event.location!.latitude}, Lng: ${event.location!.longitude}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Book Now Button
                PrimaryButton(
                  text: event.price > 0 ? 'Book Now' : 'Reserve Now',
                  onPressed: () => widget.onBookEvent(event),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
