import 'package:flutter/foundation.dart';
import '../../../app/app_constants.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  bool _isAuthenticated = false;
  bool _isGuest = false;
  String _userName = AppConstants.demoDoctorName;
  String _userEmail = AppConstants.demoEmail;
  String _userRole = AppConstants.demoRole;

  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;

  Future<bool> login({
    required String emailOrStaffId,
    required String password,
    String? role,
  }) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = true;
    _isGuest = false;
    _userName = AppConstants.demoDoctorName;
    _userEmail = emailOrStaffId.contains('@') ? emailOrStaffId : '$emailOrStaffId@phc.gov.in';
    _userRole = role ?? AppConstants.demoRole;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    _isAuthenticated = true;
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    _userRole = role;
    notifyListeners();
    return true;
  }

  void loginAsGuest() {
    _isAuthenticated = true;
    _isGuest = true;
    _userName = 'Guest Clinician';
    _userEmail = 'guest@phc.local';
    _userRole = 'Emergency Guest Access';
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isGuest = false;
    notifyListeners();
  }
}
