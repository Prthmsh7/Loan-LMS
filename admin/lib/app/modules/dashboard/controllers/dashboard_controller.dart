import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/loan_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final LoanService _loanService = Get.find<LoanService>();
  final UserService _userService = Get.find<UserService>();

  final isLoading = true.obs;
  final loans = <LoanModel>[].obs;
  final users = <UserModel>[].obs;
  
  // Dashboard statistics
  final totalUsers = 0.obs;
  final totalLoans = 0.obs;
  final pendingLoans = 0.obs;
  final approvedLoans = 0.obs;
  final rejectedLoans = 0.obs;
  final closedLoans = 0.obs;
  final totalLoanAmount = 0.0.obs;
  final disbursedAmount = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Check if user is admin
    if (!_authService.isLoggedIn) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load loans
      await _loanService.fetchLoans();
      loans.value = _loanService.loans;
      
      // Load users
      await _userService.fetchUsers();
      users.value = _userService.users;
      
      // Update statistics
      updateStatistics();
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateStatistics() {
    try {
      final loanStats = _loanService.getLoanStatistics();
      final userStats = _userService.getUserStatistics();
      
      totalUsers.value = userStats['totalUsers'] ?? 0;
      pendingLoans.value = loanStats['pendingLoans'] ?? 0;
      approvedLoans.value = loanStats['activeLoans'] ?? 0;
      rejectedLoans.value = loanStats['rejectedLoans'] ?? 0;
      closedLoans.value = loanStats['completedLoans'] ?? 0;
      totalLoans.value = pendingLoans.value + approvedLoans.value + 
                          rejectedLoans.value + closedLoans.value;
      totalLoanAmount.value = loanStats['totalAmountLent'] ?? 0.0;
      disbursedAmount.value = loanStats['totalAmountRepaid'] ?? 0.0;
    } catch (e) {
      print('Error updating statistics: $e');
    }
  }
  
  Future<void> approveLoan(String loanId) async {
    try {
      isLoading.value = true;
      await _loanService.approveLoan(loanId);
      Get.snackbar('Success', 'Loan approved successfully');
      await loadData(); // Reload data
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve loan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> rejectLoan(String loanId) async {
    try {
      isLoading.value = true;
      await _loanService.rejectLoan(loanId);
      Get.snackbar('Success', 'Loan rejected');
      await loadData(); // Reload data
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject loan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> verifyKyc(String userId) async {
    try {
      isLoading.value = true;
      await _userService.updateUserVerificationStatus(userId, 'verified');
      Get.snackbar('Success', 'User verification completed successfully');
      await loadData(); // Reload data
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify user: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> rejectKyc(String userId) async {
    try {
      isLoading.value = true;
      await _userService.updateUserVerificationStatus(userId, 'rejected');
      Get.snackbar('Success', 'User verification rejected');
      await loadData(); // Reload data
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject user verification: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter users by KYC status
  List<UserModel> getUsersByKycStatus(String status) {
    if (status == 'all') return users;
    return users.where((user) => user.kycStatus == status).toList();
  }
  
  // Search users by name or email
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return users;
    
    final lowercaseQuery = query.toLowerCase();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(lowercaseQuery) ||
             user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  // Filter loans by status
  List<LoanModel> getLoansByStatus(String status) {
    if (status == 'all') return loans;
    return loans.where((loan) => loan.status == status).toList();
  }
  
  // Filter loans by type
  List<LoanModel> getLoansByType(String type) {
    if (type == 'all') return loans;
    return loans.where((loan) => loan.loanType == type).toList();
  }
  
  // Search loans by ID or user name
  List<LoanModel> searchLoans(String query) {
    if (query.isEmpty) return loans;
    
    final lowercaseQuery = query.toLowerCase();
    return loans.where((loan) {
      final user = getUserById(loan.userId);
      return loan.id.toLowerCase().contains(lowercaseQuery) ||
             (user != null && user.fullName.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
  
  void viewLoanDetails(String loanId) {
    Get.toNamed(Routes.LOANS);
  }
  
  UserModel? getUserById(String userId) {
    try {
      if (users.isEmpty) return null;
      
      final userIndex = users.indexWhere((user) => user.id == userId);
      if (userIndex >= 0 && userIndex < users.length) {
        return users[userIndex];
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }
  
  void logout() {
    _authService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
  
  void refreshData() {
    loadData();
  }
  
  void navigateToUsers() {
    Get.toNamed(Routes.USERS);
  }
  
  void navigateToLoans() {
    Get.toNamed(Routes.LOANS);
  }
  
  void navigateToPendingLoans() {
    Get.toNamed(Routes.PENDING_LOANS);
  }
  
  void navigateToSecuritySettings() {
    Get.toNamed(Routes.SECURITY_SETTINGS);
  }
  
  void navigateToLoanSettings() {
    Get.toNamed(Routes.LOAN_SETTINGS);
  }
  
  void navigateToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }
} 