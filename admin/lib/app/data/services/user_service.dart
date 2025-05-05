import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'sync_service.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Get access to the sync service
  late SyncService _syncService;
  
  // Observable collections
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxInt _totalUsers = 0.obs;
  final RxInt _verifiedUsers = 0.obs;
  final RxInt _pendingVerificationUsers = 0.obs;
  
  // Getters
  List<UserModel> get users => _users;
  int get totalUsers => _totalUsers.value;
  int get verifiedUsers => _verifiedUsers.value;
  int get pendingVerificationUsers => _pendingVerificationUsers.value;
  
  // Initialize service
  Future<UserService> init() async {
    print('UserService initialized');
    
    try {
      // Get the sync service
      _syncService = Get.find<SyncService>();
      
      // Set up a listener for changes from the sync service
      ever(_syncService.users, _onUsersUpdated);
      
      // Fetch initial data
      if (_syncService.users.isNotEmpty) {
        _onUsersUpdated(_syncService.users);
      } else {
        await fetchUsers();
      }
    } catch (e) {
      print('Error connecting to SyncService: $e');
      // If SyncService fails, try to get data directly
      await fetchUsers();
    }
    
    return this;
  }
  
  @override
  void onInit() {
    super.onInit();
  }
  
  // Handler for when users are updated through SyncService
  void _onUsersUpdated(List<UserModel> updatedUsers) {
    // Filter out admin users
    final filteredUsers = updatedUsers.where((user) => !user.isAdmin).toList();
    
    _users.value = filteredUsers;
    
    // Update statistics
    int verified = 0;
    int pending = 0;
    
    for (var user in filteredUsers) {
      if (user.kycStatus == 'verified') {
        verified++;
      } else if (user.kycStatus == 'pending') {
        pending++;
      }
    }
    
    _totalUsers.value = filteredUsers.length;
    _verifiedUsers.value = verified;
    _pendingVerificationUsers.value = pending;
    
    print('Users updated from SyncService: ${_users.length} users');
  }
  
  // Fetch all users
  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      final List<UserModel> loadedUsers = [];
      int verified = 0;
      int pending = 0;
      
      for (var doc in snapshot.docs) {
        final userData = doc.data();
        // Filter out admin users from the regular user list
        if (userData['isAdmin'] != true) {
          final user = UserModel.fromMap({
            'id': doc.id,
            ...userData,
          });
          
          loadedUsers.add(user);
          
          // Count verified and pending users
          if (user.kycStatus == 'verified') {
            verified++;
          } else if (user.kycStatus == 'pending') {
            pending++;
          }
        }
      }
      
      // Update observable collections
      _users.value = loadedUsers;
      _totalUsers.value = loadedUsers.length;
      _verifiedUsers.value = verified;
      _pendingVerificationUsers.value = pending;
      
    } catch (e) {
      print('Error fetching users: $e');
    }
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Check if we have the user in SyncService
      final syncUser = _syncService.users.firstWhereOrNull((user) => user.id == userId);
      if (syncUser != null) {
        return syncUser;
      }
      
      // Fallback to direct Firebase query
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
  
  // Update user verification status
  Future<bool> updateUserVerificationStatus(String userId, String status) async {
    try {
      // Use SyncService to update the user verification status
      bool success = await _syncService.updateUserVerificationStatus(userId, status);
      
      if (success) {
        // Refresh users
        await fetchUsers();
      }
      
      return success;
    } catch (e) {
      print('Error updating user verification status via SyncService: $e');
      
      // Fallback to direct Firebase update
      try {
        await _firestore.collection('users').doc(userId).update({
          'kycStatus': status,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        
        // Refresh users
        await fetchUsers();
        
        return true;
      } catch (fallbackError) {
        print('Fallback error updating user verification status: $fallbackError');
        return false;
      }
    }
  }
  
  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      return _users;
    }
    
    final lowercaseQuery = query.toLowerCase();
    
    return _users.where((user) {
      return user.fullName.toLowerCase().contains(lowercaseQuery) ||
          user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  // Get user statistics
  Map<String, dynamic> getUserStatistics() {
    // Try to use SyncService statistics first
    try {
      return _syncService.getUserStatistics();
    } catch (e) {
      print('Error getting statistics from SyncService: $e');
      
      // Fallback to local calculation
      return {
        'totalUsers': _totalUsers.value,
        'verifiedUsers': _verifiedUsers.value,
        'pendingVerificationUsers': _pendingVerificationUsers.value,
        'rejectedUsers': _totalUsers.value - _verifiedUsers.value - _pendingVerificationUsers.value,
      };
    }
  }
} 