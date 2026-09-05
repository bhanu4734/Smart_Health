import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../shell/screens/main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController =
      TextEditingController(text: AppConstants.demoStaffId);
  final TextEditingController _passController =
      TextEditingController(text: AppConstants.demoPassword);
  bool _rememberMe = true;
  bool _isLoading = false;
  String _role = AppConstants.demoRole;

  final List<String> _roles = [
    'Pharmacist Officer',
    'Medical Officer (MO)',
    'Staff Nurse / Dispenser',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await AuthController().login(
      emailOrStaffId: _idController.text.trim(),
      password: _passController.text.trim(),
      role: _role,
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

  void _autoFill() {
    setState(() {
      _idController.text = AppConstants.demoStaffId;
      _passController.text = AppConstants.demoPassword;
      _role = AppConstants.demoRole;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-filled Dr. R. Warangal credentials'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
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
              constraints: const BoxConstraints(maxWidth: 420),
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
                      // Header with back button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.greenBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.greenBorder, width: 0.8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, size: 6, color: AppColors.greenDot),
                                SizedBox(width: 5),
                                Text(
                                  'Node Ready',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greenText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'CLINICAL INVENTORY NODE / Terminal Sign In',
                        style: AppTextStyles.contextNode,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppConstants.defaultFacility,
                        style: AppTextStyles.pageHeading,
                      ),
                      const Text(
                        AppConstants.defaultLocation,
                        style: AppTextStyles.subtext,
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      const SizedBox(height: 16),

                      // Role dropdown
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
                            value: _role,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                            items: _roles.map((r) {
                              return DropdownMenuItem(value: r, child: Text(r));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _role = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email or Staff ID Field
                      AppTextField(
                        label: 'Staff ID or Email Address',
                        hintText: 'e.g. PHC-WAR-882 or officer@phc.gov.in',
                        controller: _idController,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your Staff ID or Email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      AppTextField(
                        label: 'Security Passcode / PIN',
                        hintText: '••••••••',
                        controller: _passController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your passcode';
                          }
                          if (val.trim().length < 4) {
                            return 'Passcode must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Remember session
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.purpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (v) => setState(() => _rememberMe = v ?? true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember session on this device',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sign in button
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
                                    Text(
                                      'Sign In to Terminal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 16),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Autofill helper
                      Center(
                        child: TextButton.icon(
                          onPressed: _autoFill,
                          icon: const Icon(Icons.vpn_key_outlined, size: 14),
                          label: const Text('Pre-fill demo doctor credentials'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            textStyle: const TextStyle(fontSize: 12),
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
