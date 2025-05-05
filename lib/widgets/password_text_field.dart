import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String value;
  final Function(String) onChanged;
  final TextInputAction textInputAction;
  final bool isError;
  final String? errorText;

  const PasswordTextField({
    Key? key,
    required this.label,
    this.placeholder,
    required this.value,
    required this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.isError = false,
    this.errorText,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: widget.value)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: widget.value.length),
            ),
          onChanged: widget.onChanged,
          obscureText: !_isPasswordVisible,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            prefixIcon: Icon(
              Icons.lock,
              color: widget.isError
                  ? AppColors.errorLight
                  : AppColors.textColor03,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textColor03,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isError ? AppColors.errorLight : AppColors.textColor04,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isError ? AppColors.errorLight : AppColors.textColor04,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isError ? AppColors.errorLight : AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.errorLight,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.errorLight,
                width: 1.5,
              ),
            ),
            errorText: widget.isError ? widget.errorText : null,
          ),
        ),
      ],
    );
  }
}
