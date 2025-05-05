import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/password_text_field.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  final VoidCallback onLoginClick;

  const SignupScreen({
    Key? key,
    required this.onSignupSuccess,
    required this.onLoginClick,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';
  String _confirmPassword = '';
  String _countryCode = '+1';
  bool _isLoading = false;
  String? _errorMessage;

  bool _validateInputs() {
    if (_fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Full name is required';
      });
      return false;
    }

    if (_email.isEmpty) {
      setState(() {
        _errorMessage = 'Email is required';
      });
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return false;
    }

    if (_password.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required';
      });
      return false;
    }

    if (_password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return false;
    }

    if (_confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your password';
      });
      return false;
    }

    if (_password != _confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return false;
    }

    return true;
  }

  void _signup() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedPhoneNumber = _phoneNumber.isNotEmpty 
          ? '$_countryCode$_phoneNumber' 
          : null;
      
      // In a real app, this would call the actual signup method
      await _authService.simulateRegister(
        _fullName,
        _email,
        _password,
        formattedPhoneNumber,
      );
      
      if (mounted) {
        widget.onSignupSuccess();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              
              const SizedBox(height: 16),
              
              // Header
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Fill in your details to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textColor03,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Full Name field
              AppTextField(
                label: 'Full Name',
                placeholder: 'Enter your full name',
                value: _fullName,
                onChanged: (value) => setState(() => _fullName = value),
                leadingIcon: Icons.person,
              ),
              
              const SizedBox(height: 16),
              
              // Email field
              AppTextField(
                label: 'Email Address',
                placeholder: 'Enter your email',
                value: _email,
                onChanged: (value) => setState(() => _email = value),
                leadingIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              // Phone number field with country code
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code dropdown
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Country Code',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textColor04,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _countryCode,
                              items: ['+1', '+44', '+91', '+234', '+27']
                                  .map((code) => DropdownMenuItem(
                                        value: code,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(code),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _countryCode = value;
                                  });
                                }
                              },
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Phone number field
                  Expanded(
                    child: AppTextField(
                      label: 'Phone Number',
                      placeholder: 'Enter your phone number',
                      value: _phoneNumber,
                      onChanged: (value) => setState(() => _phoneNumber = value),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              PasswordTextField(
                label: 'Password',
                placeholder: 'Enter your password',
                value: _password,
                onChanged: (value) => setState(() => _password = value),
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Confirm Password field
              PasswordTextField(
                label: 'Confirm Password',
                placeholder: 'Confirm your password',
                value: _confirmPassword,
                onChanged: (value) => setState(() => _confirmPassword = value),
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.errorLight,
                      fontSize: 14,
                    ),
                  ),
                ),
              
              // Signup button
              PrimaryButton(
                text: 'Create Account',
                onPressed: _signup,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 24),
              
              // Social login divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: AppColors.textColor04,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textColor03,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: AppColors.textColor04,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google button
                  _SocialButton(
                    icon: 'assets/icons/google.png',
                    onTap: () {
                      // Handle Google signup
                    },
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Facebook button
                  _SocialButton(
                    icon: 'assets/icons/facebook.png',
                    onTap: () {
                      // Handle Facebook signup
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: widget.onLoginClick,
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textColor04,
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
