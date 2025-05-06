import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/event.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/primary_button.dart';
import 'payment_success_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final Event event;
  final int quantity;
  final String paymentMethod;
  final VoidCallback onNavigateBack;

  const PaymentConfirmationScreen({
    Key? key,
    required this.event,
    required this.quantity,
    required this.paymentMethod,
    required this.onNavigateBack,
  }) : super(key: key);

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isLoading = false;
  String _cardNumber = '';
  String _cardholderName = '';
  String _expiryDate = '';
  String _cvv = '';

  bool _validateInputs() {
    if (_cardNumber.isEmpty || _cardNumber.length < 16) {
      _showError('Please enter a valid card number');
      return false;
    }
    
    if (_cardholderName.isEmpty) {
      _showError('Please enter the cardholder name');
      return false;
    }
    
    if (_expiryDate.isEmpty || _expiryDate.length < 5) {
      _showError('Please enter a valid expiry date (MM/YY)');
      return false;
    }
    
    if (_cvv.isEmpty || _cvv.length < 3) {
      _showError('Please enter a valid CVV');
      return false;
    }
    
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorLight,
      ),
    );
  }

  void _confirmPayment() async {
    if (!_validateInputs()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            event: widget.event,
            quantity: widget.quantity,
            onBackToHome: () {
              // Navigate back to home screen
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.event.price * widget.quantity;
    final serviceFee = totalPrice * 0.1;
    final grandTotal = totalPrice + serviceFee;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
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
            
            // Payment method
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            // Selected payment method
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
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
                        widget.paymentMethod,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Card details
            Text(
              'Card Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 16),
            
            // Card number
            TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '', // Hide the counter
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
              onChanged: (value) {
                setState(() {
                  _cardNumber = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cardholder name
            TextField(
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '', // Hide the counter
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) {
                setState(() {
                  _cardholderName = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Expiry date and CVV
            Row(
              children: [
                // Expiry date
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '', // Hide the counter
                    ),
                    keyboardType: TextInputType.datetime,
                    maxLength: 5,
                    onChanged: (value) {
                      setState(() {
                        _expiryDate = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // CVV
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '', // Hide the counter
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _cvv = value;
                      });
                    },
                  ),
                ),
              ],
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
                  '\$${widget.event.price.toStringAsFixed(2)} x ${widget.quantity}',
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
                  '\$${serviceFee.toStringAsFixed(2)}',
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
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Confirm payment button
            PrimaryButton(
              text: 'Confirm Payment',
              onPressed: _confirmPayment,
              isLoading: _isLoading,
            ),
            
            const SizedBox(height: 16),
            
            // Terms and conditions
            Text(
              'By confirming your payment, you agree to our Terms of Service and Privacy Policy.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textColor03,
                  ),
              textAlign: TextAlign.center,
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
                  
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 14,
                        color: AppColors.textColor03,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Quantity: ${widget.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textColor03,
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
}
