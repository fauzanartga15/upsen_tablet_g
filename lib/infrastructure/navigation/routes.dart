class Routes {
  static Future<String> get initialRoute async {
    // TODO: implement method
    return HOME;
  }

  static const ADMIN_LOGIN = '/admin-login';
  static const CAMERA = '/camera';
  static const HOME = '/home';
  static const MANUAL_ENTRY = '/manual-entry';
  static const SUCCESS = '/success';
  static const SETTINGS = '/settings';
}

// import 'package:get/get.dart';

// import '../../app/services/auth_service.dart';
// import '../../app/services/company_service.dart';

// class Routes {
//   static Future<String> get initialRoute async {
//     // Check if admin is already logged in
//     try {
//       final authService = Get.find<AuthService>();
//       final companyService = Get.find<CompanyService>();

//       if (authService.isLoggedIn && companyService.isInitialized) {
//         return HOME;
//       }
//     } catch (e) {
//       // Services not ready yet, go to login
//     }

//     return ADMIN_LOGIN;
//   }

//   static const ADMIN_LOGIN = '/admin-login';
//   static const CAMERA = '/camera';
//   static const HOME = '/home';
//   static const MANUAL_ENTRY = '/manual-entry';
//   static const SUCCESS = '/success';
//   static const SETTINGS = '/settings';
// }
