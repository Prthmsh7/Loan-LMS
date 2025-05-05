import 'package:get/get.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxService {
  // Development mode flag - set to true to use mock credentials
  final bool _devMode = false;

  // Expose _devMode as a getter
  bool get isDevMode => _devMode;

  // Firebase instances
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user data
  final Rx<firebase_auth.User?> firebaseUser = Rx<firebase_auth.User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoggedIn => _devMode ? _currentUser.value != null : firebaseUser.value != null;
  Rx<UserModel?> get currentUser => _currentUser;

  // Initialize service
  Future<AuthService> init() async {
    print('Admin AuthService initialized');

    if (_devMode) {
      print('🔧 Development mode active - using mock admin user');
      _createMockAdminUser();
      return this;
    }
    
    // Listen to auth state changes in production mode
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      firebaseUser.value = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser.value = null;
      }
    });
    
    // Check for saved preferences
    await _checkSavedCredentials();
    
    return this;
  }
  
  @override
  void onInit() {
    super.onInit();
  }
  
  // Create a mock admin user for development
  void _createMockAdminUser() {
    final mockUser = UserModel(
      id: 'admin1',
      email: 'admin@example.com',
      fullName: 'Admin User',
      phoneNumber: '9876543210',
      isAdmin: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _currentUser.value = mockUser;
    print('🔧 Mock admin user created: ${mockUser.fullName}');
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        
        // Only allow access if user is an admin
        if (userData['isAdmin'] == true) {
          _currentUser.value = UserModel.fromMap({
            'id': uid,
            ...userData,
          });
        } else {
          // If not admin, sign out
          await signOut();
          throw 'Access denied: Admin privileges required';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Check for saved login credentials
  Future<void> _checkSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

      if (isLoggedIn) {
        final userId = prefs.getString('adminUserId');
        final userEmail = prefs.getString('adminUserEmail');
        final userName = prefs.getString('adminUserName');

        if (userId != null && userEmail != null && userName != null) {
          // Create a user from saved credentials
          final savedUser = UserModel(
            id: userId,
            email: userEmail,
            fullName: userName,
            isAdmin: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Only set if current user is null
          if (_currentUser.value == null) {
            _currentUser.value = savedUser;
            print('Admin user restored from preferences: $userId');
          }
        }
      }
    } catch (e) {
      print('Error checking saved credentials: $e');
    }
  }

  // Admin sign in
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    if (_devMode) {
      // In development mode, accept any email ending with @admin.com and password "admin"
      if (email.endsWith('@admin.com') && password == 'admin') {
        final user = UserModel(
          id: 'dev-admin-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          fullName: 'Development Admin',
          isAdmin: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        _currentUser.value = user;
        print('🔧 Development login successful: ${user.email}');
        
        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdminLoggedIn', true);
        await prefs.setString('adminUserId', user.id);
        await prefs.setString('adminUserEmail', user.email);
        await prefs.setString('adminUserName', user.fullName);
        
        return user;
      } else {
        throw 'Invalid credentials. In dev mode, use email ending with @admin.com and password "admin"';
      }
    }
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Check if user is an admin
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          
          if (userData['isAdmin'] == true) {
            final user = UserModel.fromMap({
              'id': credential.user!.uid,
              ...userData,
            });
            
            _currentUser.value = user;
            
            // Save to preferences
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isAdminLoggedIn', true);
            prefs.setString('adminUserId', user.id);
            prefs.setString('adminUserEmail', user.email);
            prefs.setString('adminUserName', user.fullName);
            
            return user;
          } else {
            await _auth.signOut();
            throw 'Access denied: Admin privileges required';
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!_devMode) {
        await _auth.signOut();
      }
      
      _currentUser.value = null;
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAdminLoggedIn', false);
      
      return;
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
} 