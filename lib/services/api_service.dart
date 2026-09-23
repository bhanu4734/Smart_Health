import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configurable API base URL (Use PC Wi-Fi IP 10.107.4.185:8000 for physical mobile/web debugging, 127.0.0.1:8000 for desktop/localhost)
  static String baseUrl = 'http://10.107.4.185:8000/api';

  // 1. Fetch All PHCs
  static Future<List<dynamic>> fetchPHCs({String? districtId, String? search}) async {
    try {
      Uri uri = Uri.parse('$baseUrl/phcs');
      Map<String, String> queryParams = {};
      if (districtId != null && districtId.isNotEmpty) queryParams['district_id'] = districtId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('ApiService.fetchPHCs error: $e');
    }
    return [];
  }

  // 2. Fetch PHC Inventory Ledger
  static Future<List<dynamic>> fetchInventoryLedger(String phcId, {String? search}) async {
    try {
      Uri uri = Uri.parse('$baseUrl/phcs/$phcId/inventory-ledger');
      if (search != null && search.isNotEmpty) {
        uri = uri.replace(queryParameters: {'search': search});
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('ApiService.fetchInventoryLedger error: $e');
    }
    return [];
  }

  // 3. Dispense Medicine
  static Future<Map<String, dynamic>> dispenseMedicine({
    required String phcId,
    required String medicineId,
    required int quantity,
    String ingestionMode = 'ui_fuzzy_search',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/phcs/$phcId/dispense-medicine');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'medicine_id': medicineId,
          'quantity': quantity,
          'ingestion_mode': ingestionMode,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.dispenseMedicine error: $e');
    }
    return {'success': false, 'message': 'Network error connection failed'};
  }

  // 4. Update PHC Capacity & Staff Attendance
  static Future<Map<String, dynamic>> updateCapacityStatus({
    required String phcId,
    int? occupiedBeds,
    int? doctorsPresent,
    int? nursesPresent,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/phcs/$phcId/update-capacity-status');
      final body = <String, dynamic>{};
      if (occupiedBeds != null) body['occupied_beds'] = occupiedBeds;
      if (doctorsPresent != null) body['doctors_present'] = doctorsPresent;
      if (nursesPresent != null) body['nurses_present'] = nursesPresent;

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.updateCapacityStatus error: $e');
    }
    return {'success': false, 'message': 'Failed to update capacity status'};
  }

  // 5. Inject Outbreak Simulation
  static Future<Map<String, dynamic>> injectOutbreak({
    String? districtId,
    String? phcId,
    double surgeFactor = 3.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/simulation/inject-outbreak');
      final body = <String, dynamic>{
        'surge_factor': surgeFactor,
      };
      if (districtId != null) body['district_id'] = districtId;
      if (phcId != null) body['phc_id'] = phcId;

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.injectOutbreak error: $e');
    }
    return {'success': false, 'message': 'Simulation injection failed'};
  }

  // 6. Execute Federated Learning Simulation
  static Future<Map<String, dynamic>> executeFederatedLearning({
    int numDistricts = 5,
    int numRounds = 3,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/federated/execute-federated-learning?num_districts=$numDistricts&num_rounds=$numRounds');
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.executeFederatedLearning error: $e');
    }
    return {'success': false, 'message': 'Federated learning execution failed'};
  }

  // 7. Fetch Stock Transfer Directives
  static Future<List<dynamic>> fetchTransferDirectives({String? status, String? phcId, String? driverId}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (phcId != null && phcId.isNotEmpty) queryParams['phc_id'] = phcId;
      if (driverId != null && driverId.isNotEmpty) queryParams['driver_id'] = driverId;

      Uri uri = Uri.parse('$baseUrl/redistribution/transfer-directives');
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('ApiService.fetchTransferDirectives error: $e');
    }
    return [];
  }

  // 8. Approve Stock Transfer Directive
  static Future<Map<String, dynamic>> approveTransfer(String transferId, {int? overrideQuantity}) async {
    try {
      String url = '$baseUrl/redistribution/approve-transfer?transfer_id=$transferId';
      if (overrideQuantity != null && overrideQuantity > 0) {
        url += '&override_quantity=$overrideQuantity';
      }
      final uri = Uri.parse(url);
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.approveTransfer error: $e');
    }
    return {'success': false, 'message': 'Approval failed'};
  }

  // 9. Execute Operations Research Stock Redistribution Optimizer
  static Future<Map<String, dynamic>> executeOptimizer({double maxTransportRadiusKm = 45.0}) async {
    try {
      final uri = Uri.parse('$baseUrl/redistribution/execute-optimizer?max_transport_radius_km=$maxTransportRadiusKm');
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.executeOptimizer error: $e');
    }
    return {'success': false, 'message': 'Optimizer execution failed'};
  }

  // 10. User Signup
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phcIdentifier,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signup');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role.contains('Admin') || role.contains('District') ? 'district_admin' : 'phc_staff',
          'phc_identifier': phcIdentifier,
        }),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        return {'success': false, 'message': body['detail'] ?? 'Signup failed'};
      }
    } catch (e) {
      print('ApiService.signup error: $e');
    }
    return {'success': false, 'message': 'Connection error during signup'};
  }

  // 11. User Login
  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username_or_email': usernameOrEmail,
          'password': password,
        }),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        return {'success': false, 'message': body['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      print('ApiService.login error: $e');
    }
    return {'success': false, 'message': 'Connection error during login'};
  }

  // 12. Submit Emergency Stock Requisition to District Portal Queue
  static Future<Map<String, dynamic>> requestEmergencyStock({
    required String phcId,
    required String medicineId,
    int requestedQuantity = 500,
    String? reason,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/redistribution/request-emergency-stock');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phc_id': phcId,
          'medicine_id': medicineId,
          'requested_quantity': requestedQuantity,
          'reason': reason,
        }),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        return {'success': false, 'message': body['detail'] ?? 'Requisition failed'};
      }
    } catch (e) {
      print('ApiService.requestEmergencyStock error: $e');
    }
    return {'success': false, 'message': 'Network error during emergency stock request'};
  }

  // 13. Fetch District Analytics Summary
  static Future<Map<String, dynamic>> fetchDistrictSummary({String? districtId}) async {
    try {
      Uri uri = Uri.parse('$baseUrl/analytics/district-summary');
      if (districtId != null && districtId.isNotEmpty) {
        uri = uri.replace(queryParameters: {'district_id': districtId});
      }
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('ApiService.fetchDistrictSummary error: $e');
    }
    return {};
  }

  // 14. Fetch Drivers & Transport Fleet
  static Future<List<dynamic>> fetchDrivers({String? districtId}) async {
    try {
      Uri uri = Uri.parse('$baseUrl/drivers');
      if (districtId != null && districtId.isNotEmpty) {
        uri = uri.replace(queryParameters: {'district_id': districtId});
      }
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['drivers'] ?? [];
      }
    } catch (e) {
      print('ApiService.fetchDrivers error: $e');
    }
    return [];
  }

  // 15. Assign Transport Driver to Directive
  static Future<Map<String, dynamic>> assignDriver({
    required String transferId,
    required String driverId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/transfers/assign-driver');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transfer_id': transferId,
          'driver_id': driverId,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      print('ApiService.assignDriver error: $e');
    }
    return {'success': false, 'message': 'Failed to assign driver'};
  }

  // 16. Driver Pickup Stock (Status -> in_transit, Generates Handover OTP)
  static Future<Map<String, dynamic>> pickupTransfer({
    required String transferId,
    required String driverId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/transfers/pickup');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transfer_id': transferId,
          'driver_id': driverId,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      print('ApiService.pickupTransfer error: $e');
    }
    return {'success': false, 'message': 'Failed to confirm pickup'};
  }

  // 17. Verify Delivery & OTP Handover (Status -> completed)
  static Future<Map<String, dynamic>> verifyDelivery({
    required String transferId,
    String? otpCode,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/transfers/verify-delivery');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transfer_id': transferId,
          'otp_code': otpCode,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      print('ApiService.verifyDelivery error: $e');
    }
    return {'success': false, 'message': 'Delivery verification failed'};
  }

  // 18. Calculate Real-Time OSRM Driving Distance & Travel Time
  static Future<Map<String, dynamic>> calculateRoute({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/distance/calculate-route');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'lat1': lat1,
          'lon1': lon1,
          'lat2': lat2,
          'lon2': lon2,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      print('ApiService.calculateRoute error: $e');
    }
    return {'success': false};
  }
}
