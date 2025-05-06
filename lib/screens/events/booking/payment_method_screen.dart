import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/event.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/primary_button.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onNavigateBack;
  final Function(Event, int, String) onProceedToConfirmation;

  const PaymentMethodScreen({
    Key? key,
    required this.event,
    required this.onNavigateBack,
    required this.onProceedToConfirmation,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _quantity = 1;
  String _selectedPaymentMethod = 'Paypal';
  
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod('Paypal', 'assets/icons/paypal.png'),
    PaymentMethod('Master Card', 'assets/icons/mastercard.png'),
    PaymentMethod('Apple Card', 'assets/icons/apple.png'),
  ];

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.event.price * _quantity;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onNavigateBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event info card
            _buildEventInfoCard(),
            
            const SizedBox(height: 24),
            
            // Quantity selector
            Text(
              'Quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                
                Text(
                  _quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment methods
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            // Payment method selection
            Column(
              children: _paymentMethods.map((method) {
                return _buildPaymentMethodItem(method);
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Order summary
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '\$${widget.event.price.toStringAsFixed(2)} x $_quantity',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Service fee (10%)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Fee (10%)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '\$${(totalPrice * 0.1).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            const Divider(),
            
            const SizedBox(height: 8),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${(totalPrice + (totalPrice * 0.1)).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Proceed button
            PrimaryButton(
              text: 'Proceed to Confirmation',
              onPressed: () {
                widget.onProceedToConfirmation(
                  widget.event,
                  _quantity,
                  _selectedPaymentMethod,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: widget.event.imageUrl != null
                    ? Image.network(
                        widget.event.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.event,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textColor03,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(widget.event.startDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textColor03,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(widget.event.startDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  if (widget.event.location != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textColor03,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.event.location!.name,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textColor03,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.name;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryLight : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.name;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment method icon placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Payment method name
              Expanded(
                child: Text(
                  method.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              
              // Radio button
              Radio<String>(
                value: method.name,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
                activeColor: AppColors.primaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final String iconPath;

  PaymentMethod(this.name, this.iconPath);
}
