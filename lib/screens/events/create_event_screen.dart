import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart';
import '../../services/event_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class CreateEventScreen extends StatefulWidget {
  final VoidCallback onNavigateBack;
  final VoidCallback onEventCreated;

  const CreateEventScreen({
    Key? key,
    required this.onNavigateBack,
    required this.onEventCreated,
  }) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventService _eventService = EventService();
  final ImagePicker _imagePicker = ImagePicker();

  // Event details
  String _title = '';
  String _description = '';
  String _category = '';
  File? _imageFile;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;
  String _location = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isFreeEvent = true;
  double _price = 0.0;
  int _capacity = 0;
  bool _isPrivateEvent = false;

  // UI state
  int _currentStep = 1;
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  String? _errorMessage;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final categories = await _eventService.simulateGetCategories();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isCategoriesLoading = false;
          
          // Set default category if available
          if (categories.isNotEmpty) {
            _category = categories.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: ${e.toString()}';
          _isCategoriesLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _navigateToNextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
    }
  }

  void _navigateToPreviousStep() {
    setState(() {
      _currentStep--;
      _errorMessage = null;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1: // Event Details
        if (_title.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter an event title';
          });
          return false;
        }
        if (_description.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter an event description';
          });
          return false;
        }
        if (_category.isEmpty) {
          setState(() {
            _errorMessage = 'Please select a category';
          });
          return false;
        }
        return true;
        
      case 2: // Location & Time
        if (_location.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter a location';
          });
          return false;
        }
        return true;
        
      case 3: // Tickets & Settings
        if (!_isFreeEvent && _price <= 0) {
          setState(() {
            _errorMessage = 'Please enter a valid price';
          });
          return false;
        }
        return true;
        
      default:
        return true;
    }
  }

  Future<void> _createEvent() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _eventService.simulateCreateEvent(
        title: _title,
        description: _description,
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
        location: _location,
        latitude: _latitude,
        longitude: _longitude,
        price: _price,
        isFreeEvent: _isFreeEvent,
        capacity: _capacity > 0 ? _capacity : null,
        isPrivateEvent: _isPrivateEvent,
        imageFile: _imageFile,
      );
      
      if (mounted) {
        widget.onEventCreated();
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
        title: const Text('Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              _navigateToPreviousStep();
            } else {
              widget.onNavigateBack();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            _buildStepProgressIndicator(),
            
            const SizedBox(height: 16),
            
            // Step title
            Text(
              _getStepTitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textColor03,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Step content
            _buildStepContent(),
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.errorLight,
                    fontSize: 14,
                  ),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final stepNumber = index + 1;
        final isActive = _currentStep >= stepNumber;
        final isLast = index == 2;
        
        return Expanded(
          child: Row(
            children: [
              // Step circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primaryLight : Colors.white,
                  border: Border.all(
                    color: isActive ? AppColors.primaryLight : AppColors.textColor04,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textColor03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Connector line
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > stepNumber
                        ? AppColors.primaryLight
                        : AppColors.textColor04,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildEventDetailsStep();
      case 2:
        return _buildLocationTimeStep();
      case 3:
        return _buildTicketsSettingsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildEventDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event title
        AppTextField(
          label: 'Event Title',
          placeholder: 'Enter event title',
          value: _title,
          onChanged: (value) => setState(() => _title = value),
        ),
        
        const SizedBox(height: 16),
        
        // Event description
        AppTextField(
          label: 'Event Description',
          placeholder: 'Enter event description',
          value: _description,
          onChanged: (value) => setState(() => _description = value),
          maxLines: 5,
        ),
        
        const SizedBox(height: 16),
        
        // Category dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _isCategoriesLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textColor04,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category.isNotEmpty ? _category : null,
                        hint: const Text('Select a category'),
                        items: _categories
                            .map((category) => DropdownMenuItem(
                                  value: category.name,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(category.name),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: Theme.of(context).textTheme.bodyMedium,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Event image
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Image',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textColor04,
                    width: 1,
                  ),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: AppColors.textColor03,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add an image',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        AppTextField(
          label: 'Location',
          placeholder: 'Enter event location',
          value: _location,
          onChanged: (value) => setState(() => _location = value),
          leadingIcon: Icons.location_on,
        ),
        
        const SizedBox(height: 24),
        
        // Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime.now().add(const Duration(days: 365)),
                  onConfirm: (date) {
                    setState(() {
                      _startDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _startDate.hour,
                        _startDate.minute,
                      );
                      
                      // If end date is before start date, update it
                      if (_endDate != null && _endDate!.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(hours: 2));
                      }
                    });
                  },
                  currentTime: _startDate,
                  locale: LocaleType.en,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textColor04,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.textColor03,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Start Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Time',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  onConfirm: (time) {
                    setState(() {
                      _startDate = DateTime(
                        _startDate.year,
                        _startDate.month,
                        _startDate.day,
                        time.hour,
                        time.minute,
                      );
                      
                      // If end date is before start date, update it
                      if (_endDate != null && _endDate!.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(hours: 2));
                      }
                    });
                  },
                  currentTime: _startDate,
                  locale: LocaleType.en,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textColor04,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.textColor03,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      DateFormat('h:mm a').format(_startDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // End Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'End Time',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Switch(
                  value: _endDate != null,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _endDate = _startDate.add(const Duration(hours: 2));
                      } else {
                        _endDate = null;
                      }
                    });
                  },
                  activeColor: AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_endDate != null)
              GestureDetector(
                onTap: () {
                  DatePicker.showTimePicker(
                    context,
                    showTitleActions: true,
                    onConfirm: (time) {
                      final newEndDate = DateTime(
                        _startDate.year,
                        _startDate.month,
                        _startDate.day,
                        time.hour,
                        time.minute,
                      );
                      
                      // Ensure end time is after start time
                      if (newEndDate.isAfter(_startDate)) {
                        setState(() {
                          _endDate = newEndDate;
                        });
                      } else {
                        setState(() {
                          _errorMessage = 'End time must be after start time';
                        });
                      }
                    },
                    currentTime: _endDate ?? _startDate.add(const Duration(hours: 2)),
                    locale: LocaleType.en,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textColor04,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textColor03,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('h:mm a').format(_endDate!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketsSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Free event toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Free Event',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Switch(
              value: _isFreeEvent,
              onChanged: (value) {
                setState(() {
                  _isFreeEvent = value;
                  if (value) {
                    _price = 0.0;
                  }
                });
              },
              activeColor: AppColors.primaryLight,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Price (if not free)
        if (!_isFreeEvent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: _price.toString())
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: _price.toString().length),
                  ),
                onChanged: (value) {
                  final price = double.tryParse(value);
                  if (price != null) {
                    setState(() {
                      _price = price;
                    });
                  }
                },
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixIconColor: AppColors.textColor03,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textColor04,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textColor04,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryLight,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        
        // Capacity
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capacity (optional)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _capacity > 0 ? _capacity.toString() : '')
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _capacity > 0 ? _capacity.toString().length : 0),
                ),
              onChanged: (value) {
                final capacity = int.tryParse(value);
                setState(() {
                  _capacity = capacity ?? 0;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter maximum number of attendees',
                prefixIcon: const Icon(Icons.people),
                prefixIconColor: AppColors.textColor03,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.textColor04,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.textColor04,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Private event toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private Event',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'Only visible to invited guests',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textColor03,
                  ),
                ),
              ],
            ),
            Switch(
              value: _isPrivateEvent,
              onChanged: (value) {
                setState(() {
                  _isPrivateEvent = value;
                });
              },
              activeColor: AppColors.primaryLight,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: _navigateToPreviousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.textColor03),
              ),
              child: const Text('Back'),
            ),
          ),
        
        if (_currentStep > 1)
          const SizedBox(width: 16),
        
        Expanded(
          child: _currentStep < 3
              ? PrimaryButton(
                  text: 'Next',
                  onPressed: _navigateToNextStep,
                )
              : PrimaryButton(
                  text: 'Create Event',
                  onPressed: _createEvent,
                  isLoading: _isLoading,
                ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Step 1 of 3: Event Details';
      case 2:
        return 'Step 2 of 3: Location & Time';
      case 3:
        return 'Step 3 of 3: Tickets & Settings';
      default:
        return '';
    }
  }
}
