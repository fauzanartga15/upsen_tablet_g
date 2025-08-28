// lib/app/services/company_service.dart
import 'package:get/get.dart';
import '../data/providers/company_api.dart';

class CompanyService extends GetxService {
  final CompanyApi _api = CompanyApi();

  // Immutable during session - set once during admin login
  String companyId = '';
  String branchId = '';

  // Reactive company info
  final Rxn<Company> _currentCompany = Rxn<Company>();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  Company? get currentCompany => _currentCompany.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isInitialized => companyId.isNotEmpty && branchId.isNotEmpty;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Will be set during admin login flow
  }

  // Set company context during admin login
  Future<bool> setCompanyContext(String cId, String bId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      companyId = cId;
      branchId = bId;

      // Fetch company details
      final response = await _api.getCompany();
      if (response.isOk && response.body != null) {
        _currentCompany.value = Company.fromJson(response.body);

        print("Company context set:");
        print("  Company ID: $companyId");
        print("  Branch ID: $branchId");
        print("  Company Name: ${_currentCompany.value?.name}");

        return true;
      } else {
        throw Exception('Failed to fetch company data: ${response.statusText}');
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print("Error setting company context: $e");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get company display name for UI
  String get companyDisplayName {
    return _currentCompany.value?.name ?? 'Unknown Company';
  }

  // Get company logo URL
  String? get companyLogoUrl {
    return _currentCompany.value?.logoUrl;
  }

  // Get company working hours
  Map<String, String>? get workingHours {
    return _currentCompany.value?.workingHours;
  }

  // Get company theme colors if available
  Map<String, String>? get themeColors {
    return _currentCompany.value?.themeColors;
  }

  // Clear company context (logout)
  void clearContext() {
    companyId = '';
    branchId = '';
    _currentCompany.value = null;
    _errorMessage.value = '';
    print("Company context cleared");
  }

  // Validate if current context is still valid
  Future<bool> validateContext() async {
    if (!isInitialized) return false;

    try {
      final response = await _api.getCompany();
      return response.isOk;
    } catch (e) {
      print("Context validation failed: $e");
      return false;
    }
  }
}

// lib/app/data/models/company_model.dart
class Company {
  final String id;
  final String name;
  final String? logoUrl;
  final String? address;
  final Map<String, String>? workingHours;
  final Map<String, String>? themeColors;
  final DateTime? createdAt;

  Company({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.workingHours,
    this.themeColors,
    this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'],
      address: json['address'],
      workingHours: json['working_hours'] != null
          ? Map<String, String>.from(json['working_hours'])
          : null,
      themeColors: json['theme_colors'] != null
          ? Map<String, String>.from(json['theme_colors'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'working_hours': workingHours,
      'theme_colors': themeColors,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
