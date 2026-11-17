import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/shared_design_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _nameController = TextEditingController(text: 'Alina Raza');
  final _emailController = TextEditingController(text: 'alina.raza@gmail.com');
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Shield Icon (Fig 13.11)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 24),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Create your account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'An account is needed for the Pro trial, cloud backup and using Pro on more than one phone. Your current applications are kept.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Google Sign-In Button
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connected with Google! Data safely linked.')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.g_mobiledata_rounded, color: AppColors.primaryBlue, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or use email',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // Full Name Field
            const Text('Full name', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            // Email Field
            const Text('Email', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            // Password Field
            const Text('Password', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.lock_outline : Icons.lock_open_rounded, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'At least 8 characters. We will send a link to verify your email.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Create account',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification link sent to email! Local data linked.')),
                );
              },
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'By continuing you agree to the Terms and Privacy Policy.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
