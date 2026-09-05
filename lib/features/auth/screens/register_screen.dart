import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../shell/screens/main_shell_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  String _selectedRole = 'Staff Nurse / Dispenser';
  bool _isLoading = false;

  final List<String> _roles = [
    'Pharmacist Officer',
    'Medical Officer (MO)',
    'Staff Nurse / Dispenser',
    'District Inventory Logistics Officer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await AuthController().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      role: _selectedRole,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShellScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: AppColors.purpleAccent,
                    width: isMobile ? 2.5 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleAccent.withValues(alpha: 0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            AppConstants.appName,
                            style: AppTextStyles.brandTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'NEW PERSONNEL ENROLLMENT',
                        style: AppTextStyles.contextNode,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create Account',
                        style: AppTextStyles.pageHeading,
                      ),
                      const Text(
                        'Enroll terminal operator for Warangal Health Jurisdiction.',
                        style: AppTextStyles.subtext,
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      const SizedBox(height: 16),

                      // Full Name
                      AppTextField(
                        label: 'Full Name & Designation',
                        hintText: 'e.g. Dr. Priya Sharma',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Clinical Role dropdown
                      const Text(
                        'Operational Role',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                            items: _roles.map((r) {
                              return DropdownMenuItem(value: r, child: Text(r));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedRole = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Official Email
                      AppTextField(
                        label: 'Official Email Address',
                        hintText: 'e.g. p.sharma@phc.telangana.gov.in',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      AppTextField(
                        label: 'Create Passcode / Password',
                        hintText: 'At least 6 characters',
                        controller: _passController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a password';
                          }
                          if (val.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password
                      AppTextField(
                        label: 'Confirm Passcode',
                        hintText: 'Re-enter passcode',
                        controller: _confirmPassController,
                        isPassword: true,
                        prefixIcon: Icons.lock_reset_rounded,
                        validator: (val) {
                          if (val != _passController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Complete Registration',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
