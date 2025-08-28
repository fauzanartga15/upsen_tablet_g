// lib/main.dart - Complete service initialization
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/services/auth_service.dart';
import 'app/services/company_service.dart';
import 'app/services/face_recognition_service.dart';
import 'app/services/offline_sync_service.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for responsive tablet/phone
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initializeServices();

  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

Future<void> _initializeServices() async {
  print("🚀 Initializing Upsen Tablet services...");

  try {
    // Core services (no dependencies)
    Get.put(AuthService(), permanent: true);
    print("✅ AuthService initialized");

    Get.put(CompanyService(), permanent: true);
    print("✅ CompanyService initialized");

    // Face recognition service (async initialization)
    await Get.putAsync(() => FaceRecognitionService.init(), permanent: true);
    print("✅ FaceRecognitionService initialized");

    // Offline sync service (depends on database)
    await Get.putAsync(() => OfflineSyncService().init(), permanent: true);
    print("✅ OfflineSyncService initialized");

    print("🎉 All services initialized successfully");
  } catch (e) {
    print("❌ Service initialization failed: $e");
    // Could show error dialog here
  }
}

extension on OfflineSyncService {
  Future<OfflineSyncService> init() async {
    await onInit();
    return this;
  }
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Upsen Tablet',
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
