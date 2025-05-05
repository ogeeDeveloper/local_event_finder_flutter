import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/password_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSignUpClick;
  final VoidCallback onForgotPasswordClick;

  const LoginScreen({
    Key? key,
    required this.onLoginSuccess,
    required this.onSignUpClick,
    required this.onForgotPasswordClick,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  
  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isEmailError = false;
  bool _isPasswordError = false;
  String? _errorMessage;

  void _login() async {
    // Validate inputs
    if (_email.isEmpty) {
      setState(() {
        _isEmailError = true;
        _errorMessage = 'Email is required';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email)) {
      setState(() {
        _isEmailError = true;
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    if (_password.isEmpty) {
      setState(() {
        _isPasswordError = true;
        _errorMessage = 'Password is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isEmailError = false;
      _isPasswordError = false;
    });

    try {
      // In a real app, this would call the actual login method
      await _authService.simulateLogin(_email, _password);
      
      if (mounted) {
        widget.onLoginSuccess();
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
                'Login to your account',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Hi, Welcome back',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textColor03,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Email field
              AppTextField(
                label: 'Email Address',
                placeholder: 'Enter your email',
                value: _email,
                onChanged: (value) => setState(() => _email = value),
                leadingIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                isError: _isEmailError,
                errorText: _isEmailError ? _errorMessage : null,
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              PasswordTextField(
                label: 'Password',
                placeholder: 'Enter your password',
                value: _password,
                onChanged: (value) => setState(() => _password = value),
                isError: _isPasswordError,
                errorText: _isPasswordError ? _errorMessage : null,
              ),
              
              const SizedBox(height: 8),
              
              // Remember me and Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Remember me
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryLight,
                      ),
                      Text(
                        'Remember me',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  
                  // Forgot password
                  TextButton(
                    onPressed: widget.onForgotPasswordClick,
                    child: Text(
                      'Forgot password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null && !_isEmailError && !_isPasswordError)
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
              
              // Login button
              PrimaryButton(
                text: 'Login',
                onPressed: _login,
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
                      // Handle Google login
                    },
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Facebook button
                  _SocialButton(
                    icon: 'assets/icons/facebook.png',
                    onTap: () {
                      // Handle Facebook login
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: widget.onSignUpClick,
                    child: Text(
                      'Sign Up',
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
