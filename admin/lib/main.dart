import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/loan_service.dart';
import 'app/data/services/user_service.dart';
import 'app/data/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Global error handler for pigeon-related errors
Future<void> _handlePigeonError(Object error, StackTrace stack) async {
  if (error.toString().contains('PigeonUserDetails')) {
    debugPrint('Caught PigeonUserDetails error, suppressing: $error');
    // Don't report this error as it's expected and handled
  } else {
    // For other errors, use the default error handling
    FlutterError.presentError(FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'Loan Admin App',
      context: ErrorDescription('during app initialization'),
    ));
  }
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint('Starting app initialization...');
      
      // Initialize SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      Get.put(prefs);
      
      // Initialize Firebase with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase initialized successfully');
      
      // Initialize services in the correct order
      try {
        // 1. First initialize Auth
        await Get.putAsync(() => AuthService().init());
        debugPrint('AuthService initialized');
        
        // 2. Initialize SyncService next, as others depend on it
        await Get.putAsync(() => SyncService().init());
        debugPrint('SyncService initialized');
        
        // 3. Initialize UserService after SyncService
        await Get.putAsync(() => UserService().init());
        debugPrint('UserService initialized');
        
        // 4. Initialize LoanService last
        await Get.putAsync(() => LoanService().init());
        debugPrint('LoanService initialized');
      } catch (e) {
        debugPrint('Failed to initialize services: $e');
        // Continue app startup even if services fail
      }
      
      debugPrint('App initialized successfully');
      
      runApp(const AdminApp());
    } catch (e, stackTrace) {
      debugPrint('Fatal error during app initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      // Display an error screen instead of crashing
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Startup Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Failed to initialize the app: $e',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }, (error, stack) {
    // Handle any errors that occur during app execution
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
    _handlePigeonError(error, stack);
  });
}

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loan Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF2196F3),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
} 