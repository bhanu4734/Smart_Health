import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/app_constants.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  bool _isAuthenticated = false;
  bool _hasSeenTour = false;
  String _userName = AppConstants.demoDoctorName;
  String _userEmail = AppConstants.demoEmail;
  String _userRole = AppConstants.demoRole;
  String _phcId = 'PHC-D01-03';
  String _phcName = 'Nalgonda Area PHC #3';

  bool get isAuthenticated => _isAuthenticated;
  bool get hasSeenTour => _hasSeenTour;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  String get phcId => _phcId;
  String get phcName => _phcName;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      _hasSeenTour = prefs.getBool('has_seen_tour') ?? false;
      _userName = prefs.getString('user_name') ?? AppConstants.demoDoctorName;
      _userEmail = prefs.getString('user_email') ?? AppConstants.demoEmail;
      _userRole = prefs.getString('user_role') ?? AppConstants.demoRole;
      _phcId = prefs.getString('phc_id') ?? 'PHC-D01-03';
      _phcName = prefs.getString('phc_name') ?? 'Nalgonda Area PHC #3';
      notifyListeners();
    } catch (e) {
      print('AuthController.init error: $e');
    }
  }

  Future<void> completeTour() async {
    _hasSeenTour = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_tour', true);
    } catch (e) {
      print('AuthController.completeTour error: $e');
    }
  }

  void setPhcData(String id, String name) async {
    _phcId = id;
    _phcName = name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phc_id', id);
      await prefs.setString('phc_name', name);
    } catch (e) {}
  }

  Future<bool> login({
    required String emailOrStaffId,
    required String password,
    String? role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _isAuthenticated = true;
    _userName = AppConstants.demoDoctorName;
    _userEmail = emailOrStaffId.contains('@') ? emailOrStaffId : '$emailOrStaffId@phc.gov.in';
    _userRole = role ?? AppConstants.demoRole;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('user_role', _userRole);
      await prefs.setString('phc_id', _phcId);
      await prefs.setString('phc_name', _phcName);
    } catch (e) {
      print('AuthController.login persist error: $e');
    }

    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userRole = role;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('user_role', _userRole);
      await prefs.setString('phc_id', _phcId);
      await prefs.setString('phc_name', _phcName);
    } catch (e) {}

    return true;
  }

  void logout() async {
    _isAuthenticated = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', false);
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    } catch (e) {}
  }
}
