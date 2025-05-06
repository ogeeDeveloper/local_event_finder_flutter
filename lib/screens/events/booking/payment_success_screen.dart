import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/event.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/primary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Event event;
  final int quantity;
  final VoidCallback onBackToHome;

  const PaymentSuccessScreen({
    Key? key,
    required this.event,
    required this.quantity,
    required this.onBackToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPrice = event.price * quantity;
    final serviceFee = totalPrice * 0.1;
    final grandTotal = totalPrice + serviceFee;
    
    // Generate a random booking ID
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Success'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.successLight,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Success message
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.successLight,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Your booking has been confirmed',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Booking details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking ID',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Text(
                        bookingId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Event',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.startDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(event.startDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor03,
                            ),
                      ),
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // QR code placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking QR Code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textColor03,
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Back to home button
            PrimaryButton(
              text: 'Back to Home',
              onPressed: onBackToHome,
            ),
            
            const SizedBox(height: 16),
            
            // Download ticket button
            TextButton.icon(
              onPressed: () {
                // Show a snackbar indicating this is a demo feature
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download ticket feature is not implemented in this demo'),
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Ticket'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
