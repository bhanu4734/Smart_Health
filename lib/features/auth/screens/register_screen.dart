import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/api_service.dart';
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
  final TextEditingController _phcIdController = TextEditingController(text: 'PHC-D01-03');
  String _selectedRole = '🏥 PHC Medical Officer (Facility Stock Manager)';
  bool _isLoading = false;
  List<dynamic> _phcList = [];

  final List<String> _roles = [
    '🏢 District Medical Officer (DMO / District Admin)',
    '🏥 PHC Medical Officer (Facility Stock Manager)',
    '🚚 Cold-Chain Fleet Driver (Logistics & OTP Transport)',
  ];

  @override
  void initState() {
    super.initState();
    _loadPhcs();
  }

  Future<void> _loadPhcs() async {
    final list = await ApiService.fetchPHCs();
    if (!mounted) return;
    setState(() => _phcList = list);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _phcIdController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await ApiService.signup(
      username: _emailController.text.trim().split('@').first,
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      fullName: _nameController.text.trim(),
      role: _selectedRole,
      phcIdentifier: _phcIdController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      final user = res['user'] ?? {};
      final phcId = user['phc_id'] ?? _phcIdController.text.trim();
      final phcName = user['phc_name'] ?? _phcIdController.text.trim();

      AuthController().setPhcData(phcId, phcName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? '🎉 Account created for $phcName! Logged in.'),
          backgroundColor: AppColors.purpleAccent,
        ),
      );

      await AuthController().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        role: _selectedRole,
      );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MainShellScreen(userRole: _selectedRole),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Registration failed. Check PHC ID/Name.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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

                      if (_selectedRole.contains('Manager')) ...[
                        if (_phcList.isNotEmpty) ...[
                          const Text(
                            'Select PHC Health Center (from Database)',
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
                                value: _phcList.any((p) => p['id'] == _phcIdController.text)
                                    ? _phcIdController.text
                                    : _phcList.first['id'],
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                items: _phcList.map((p) {
                                  return DropdownMenuItem<String>(
                                    value: p['id'].toString(),
                                    child: Text('${p['name']} (${p['id']})'),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _phcIdController.text = v);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ] else ...[
                          AppTextField(
                            label: 'PHC Center ID or Name',
                            hintText: 'e.g. PHC-D01-03 or Nalgonda Area PHC #3',
                            controller: _phcIdController,
                            prefixIcon: Icons.local_hospital_outlined,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your PHC Center ID or Name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],

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
