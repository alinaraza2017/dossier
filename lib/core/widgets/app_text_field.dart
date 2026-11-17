import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
