import 'package:flutter/foundation.dart';
import '../../../app/app_constants.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  bool _isAuthenticated = false;
  String _userName = AppConstants.demoDoctorName;
  String _userEmail = AppConstants.demoEmail;
  String _userRole = AppConstants.demoRole;
  String _phcId = 'PHC-D01-03';
  String _phcName = 'Nalgonda Area PHC #3';

  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => false;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  String get phcId => _phcId;
  String get phcName => _phcName;

  void setPhcData(String id, String name) {
    _phcId = id;
    _phcName = name;
    notifyListeners();
  }

  Future<bool> login({
    required String emailOrStaffId,
    required String password,
    String? role,
  }) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = true;
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
    _userName = name;
    _userEmail = email;
    _userRole = role;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
