import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class SyncService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the auth service to check if we're in dev mode
  final AuthService _authService = Get.find<AuthService>();
  
  // Development mode flag - will be true if AuthService is in dev mode
  bool get _devMode => _authService.isDevMode;
  
  // Observable lists for real-time updates
  final RxList<LoanModel> loans = <LoanModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  
  // Streams for listening to changes
  Stream<QuerySnapshot>? _loansStream;
  Stream<QuerySnapshot>? _usersStream;
  
  // For storing admin actions
  final RxList<Map<String, dynamic>> adminActions = <Map<String, dynamic>>[].obs;
  
  // Initialize service
  Future<SyncService> init() async {
    print('SyncService initialized');
    
    if (_devMode) {
      print('🔧 SyncService in development mode - using mock data');
      _createMockData();
      return this;
    }
    
    try {
      // Initialize streams
      _loansStream = _firestore.collection('loans').snapshots();
      _usersStream = _firestore.collection('users').snapshots();
      
      // Start listening to changes
      _setupLoansListener();
      _setupUsersListener();
      
      // Record sync initialization
      await _recordAdminAction('sync_initialized', 'Admin app initialized sync service');
    } catch (e) {
      print('Error initializing Firebase listeners: $e');
      print('Error details: $e');
      throw Exception('Failed to initialize Firebase: $e');
    }
    
    return this;
  }
  
  // Create mock data for development
  void _createMockData() {
    // Create mock users
    final mockUsers = [
      UserModel(
        id: 'user1',
        email: 'user1@example.com',
        fullName: 'John Doe',
        phoneNumber: '1234567890',
        address: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
        kycStatus: 'pending',
        isAdmin: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'user2',
        email: 'user2@example.com',
        fullName: 'Jane Smith',
        phoneNumber: '0987654321',
        address: '456 Oak Ave',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90001',
        country: 'USA',
        kycStatus: 'verified',
        isAdmin: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'user3',
        email: 'user3@example.com',
        fullName: 'Bob Johnson',
        phoneNumber: '5551234567',
        address: '789 Pine St',
        city: 'Chicago',
        state: 'IL',
        zipCode: '60007',
        country: 'USA',
        kycStatus: 'rejected',
        isAdmin: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    
    // Create mock loans
    final now = DateTime.now();
    final mockLoans = [
      LoanModel(
        id: 'loan1',
        userId: 'user1',
        amount: 50000,
        emiAmount: 5000,
        tenureMonths: 12,
        interestRate: 10.5,
        status: 'pending',
        applicationDate: now.subtract(const Duration(days: 2)),
        approvalDate: null,
        dueDate: now.add(const Duration(days: 28)),
        paymentDates: [],
        loanType: 'personal',
        purpose: 'Home Renovation',
        totalInstallments: 12,
        paidInstallments: 0,
        amountPaid: 0,
        remainingAmount: 50000,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        repayments: [],
        userName: 'John Doe',
      ),
      LoanModel(
        id: 'loan2',
        userId: 'user2',
        amount: 100000,
        emiAmount: 9000,
        tenureMonths: 12,
        interestRate: 8.5,
        status: 'approved',
        applicationDate: now.subtract(const Duration(days: 10)),
        approvalDate: now.subtract(const Duration(days: 8)),
        dueDate: now.add(const Duration(days: 20)),
        paymentDates: [
          now.subtract(const Duration(days: 7)),
        ],
        loanType: 'business',
        purpose: 'Inventory Purchase',
        totalInstallments: 12,
        paidInstallments: 1,
        amountPaid: 9000,
        remainingAmount: 91000,
        startDate: now.subtract(const Duration(days: 8)),
        endDate: now.add(const Duration(days: 357)),
        repayments: [
          RepaymentModel(
            id: 'rep1',
            amount: 9000,
            date: now.subtract(const Duration(days: 7)),
            status: 'paid',
          ),
        ],
        userName: 'Jane Smith',
      ),
      LoanModel(
        id: 'loan3',
        userId: 'user3',
        amount: 30000,
        emiAmount: 10500,
        tenureMonths: 3,
        interestRate: 12.0,
        status: 'rejected',
        applicationDate: now.subtract(const Duration(days: 5)),
        approvalDate: null,
        dueDate: now,
        paymentDates: [],
        loanType: 'quick_cash',
        purpose: 'Medical Expenses',
        totalInstallments: 3,
        paidInstallments: 0,
        amountPaid: 0,
        remainingAmount: 30000,
        startDate: now,
        endDate: now.add(const Duration(days: 90)),
        repayments: [],
        userName: 'Bob Johnson',
      ),
    ];
    
    // Set the mock data
    loans.value = mockLoans;
    users.value = mockUsers;
    
    // Add mock admin actions
    adminActions.addAll([
      {
        'actionType': 'loan_approved',
        'description': 'Loan loan2 approved for Jane Smith',
        'adminId': 'admin1',
        'adminEmail': 'admin@example.com',
        'timestamp': DateTime.now().subtract(const Duration(days: 8)).millisecondsSinceEpoch,
        'platform': 'admin_app',
      },
      {
        'actionType': 'loan_rejected',
        'description': 'Loan loan3 rejected for Bob Johnson - Reason: Insufficient income documentation',
        'adminId': 'admin1',
        'adminEmail': 'admin@example.com',
        'timestamp': DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch,
        'platform': 'admin_app',
      },
      {
        'actionType': 'user_verification',
        'description': 'User user2 verification status updated to verified',
        'adminId': 'admin1',
        'adminEmail': 'admin@example.com',
        'timestamp': DateTime.now().subtract(const Duration(days: 15)).millisecondsSinceEpoch,
        'platform': 'admin_app',
      },
    ]);
    
    print('🔧 Created mock data: ${users.length} users and ${loans.length} loans');
  }
  
  // Listen to loan changes
  void _setupLoansListener() {
    if (_loansStream == null) return;
    
    _loansStream!.listen((snapshot) {
      final List<LoanModel> updatedLoans = [];
      
      for (var doc in snapshot.docs) {
        try {
          final loanData = doc.data() as Map<String, dynamic>;
          final loan = LoanModel.fromMap({
            'id': doc.id,
            ...loanData,
          });
          updatedLoans.add(loan);
        } catch (e) {
          print('Error parsing loan document: $e');
        }
      }
      
      loans.value = updatedLoans;
      print('Loans updated from Firebase: ${loans.length} loans');
    }, onError: (error) {
      print('Error listening to loans: $error');
      if (loans.isEmpty) {
        _createMockData();
      }
    });
  }
  
  // Listen to user changes
  void _setupUsersListener() {
    if (_usersStream == null) return;
    
    _usersStream!.listen((snapshot) {
      final List<UserModel> updatedUsers = [];
      
      for (var doc in snapshot.docs) {
        try {
          final userData = doc.data() as Map<String, dynamic>;
          final user = UserModel.fromMap({
            'id': doc.id,
            ...userData,
          });
          updatedUsers.add(user);
        } catch (e) {
          print('Error parsing user document: $e');
        }
      }
      
      users.value = updatedUsers;
      print('Users updated from Firebase: ${users.length} users');
    }, onError: (error) {
      print('Error listening to users: $error');
      if (users.isEmpty) {
        _createMockData();
      }
    });
  }
  
  // Record admin actions for audit
  Future<void> _recordAdminAction(String actionType, String description) async {
    try {
      if (_devMode) {
        // In dev mode, just store locally
        final adminUser = _authService.currentUser.value;
        
        final actionData = {
          'actionType': actionType,
          'description': description,
          'adminId': adminUser?.id ?? 'dev-admin',
          'adminEmail': adminUser?.email ?? 'admin@example.com',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'platform': 'admin_app',
        };
        
        // Record locally
        adminActions.add(actionData);
        print('🔧 Admin action recorded (dev mode): $actionType');
        return;
      }
      
      final user = _auth.currentUser;
      final adminUser = _authService.currentUser.value;
      
      final actionData = {
        'actionType': actionType,
        'description': description,
        'adminId': user?.uid ?? adminUser?.id ?? 'unknown',
        'adminEmail': user?.email ?? adminUser?.email ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'platform': 'admin_app',
      };
      
      // Record locally
      adminActions.add(actionData);
      
      // Record to Firebase
      await _firestore.collection('admin_actions').add(actionData);
      
    } catch (e) {
      print('Error recording admin action: $e');
    }
  }
  
  // Update loan status (approve/reject)
  Future<bool> updateLoanStatus(String loanId, String status, {String? rejectionReason}) async {
    try {
      if (_devMode) {
        // Update mock loan
        final index = loans.indexWhere((loan) => loan.id == loanId);
        if (index >= 0) {
          final loan = loans[index];
          final now = DateTime.now();
          
          // Create updated loan object
          final updatedLoan = LoanModel(
            id: loan.id,
            userId: loan.userId,
            amount: loan.amount,
            emiAmount: loan.emiAmount,
            tenureMonths: loan.tenureMonths,
            interestRate: loan.interestRate,
            status: status,
            applicationDate: loan.applicationDate,
            approvalDate: status == 'approved' ? now : loan.approvalDate,
            dueDate: status == 'approved' ? now.add(const Duration(days: 30)) : loan.dueDate,
            paymentDates: loan.paymentDates,
            loanType: loan.loanType,
            purpose: loan.purpose,
            totalInstallments: loan.totalInstallments,
            paidInstallments: loan.paidInstallments,
            amountPaid: loan.amountPaid,
            remainingAmount: loan.remainingAmount,
            startDate: status == 'approved' ? now : loan.startDate,
            endDate: status == 'approved' ? now.add(Duration(days: 30 * loan.tenureMonths)) : loan.endDate,
            repayments: loan.repayments,
            userName: loan.userName,
          );
          
          loans[index] = updatedLoan;
          
          // Record action
          await _recordAdminAction(
            'loan_${status}', 
            'Loan $loanId ${status == 'approved' ? 'approved' : 'rejected'}${rejectionReason != null ? ' - Reason: $rejectionReason' : ''}'
          );
          
          print('🔧 Updated loan status (dev mode): $loanId to $status');
          return true;
        }
        return false;
      }
      
      final data = {
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (status == 'approved') {
        data['approvalDate'] = DateTime.now().millisecondsSinceEpoch;
      }
      
      if (status == 'rejected' && rejectionReason != null) {
        data['rejectionReason'] = rejectionReason;
      }
      
      await _firestore.collection('loans').doc(loanId).update(data);
      
      // Record action
      await _recordAdminAction(
        'loan_${status}', 
        'Loan $loanId ${status == 'approved' ? 'approved' : 'rejected'}${rejectionReason != null ? ' - Reason: $rejectionReason' : ''}'
      );
      
      return true;
    } catch (e) {
      print('Error updating loan status: $e');
      return false;
    }
  }
  
  // Update user verification status
  Future<bool> updateUserVerificationStatus(String userId, String status) async {
    try {
      if (_devMode) {
        // Update mock user
        final index = users.indexWhere((user) => user.id == userId);
        if (index >= 0) {
          final user = users[index];
          
          final updatedUser = UserModel(
            id: user.id,
            email: user.email,
            fullName: user.fullName,
            phoneNumber: user.phoneNumber,
            address: user.address,
            city: user.city,
            state: user.state,
            zipCode: user.zipCode,
            country: user.country,
            kycStatus: status,
            isAdmin: user.isAdmin,
            createdAt: user.createdAt,
            updatedAt: DateTime.now(),
          );
          
          users[index] = updatedUser;
          
          // Record action
          await _recordAdminAction(
            'user_verification', 
            'User $userId verification status updated to $status'
          );
          
          print('🔧 Updated user verification status (dev mode): $userId to $status');
          return true;
        }
        return false;
      }
      
      await _firestore.collection('users').doc(userId).update({
        'kycStatus': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Record action
      await _recordAdminAction(
        'user_verification', 
        'User $userId verification status updated to $status'
      );
      
      return true;
    } catch (e) {
      print('Error updating user verification status: $e');
      return false;
    }
  }
  
  // Get real-time loan statistics
  Map<String, dynamic> getLoanStatistics() {
    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;
    int closedCount = 0;
    double totalLent = 0.0;
    double totalRepaid = 0.0;
    double totalInterestEarned = 0.0;
    
    for (var loan in loans) {
      switch (loan.status) {
        case 'pending':
          pendingCount++;
          break;
        case 'approved':
          approvedCount++;
          totalLent += loan.amount;
          totalRepaid += loan.amountPaid;
          final interestPaid = loan.amountPaid - (loan.amount / loan.totalInstallments * loan.paidInstallments);
          if (interestPaid > 0) {
            totalInterestEarned += interestPaid;
          }
          break;
        case 'rejected':
          rejectedCount++;
          break;
        case 'closed':
          closedCount++;
          totalLent += loan.amount;
          totalRepaid += loan.amountPaid;
          break;
      }
    }
    
    return {
      'totalAmountLent': totalLent,
      'totalAmountRepaid': totalRepaid,
      'totalInterestEarned': totalInterestEarned,
      'activeLoans': approvedCount,
      'pendingLoans': pendingCount,
      'completedLoans': closedCount,
      'rejectedLoans': rejectedCount,
    };
  }
  
  // Get real-time user statistics
  Map<String, dynamic> getUserStatistics() {
    int totalCount = users.length;
    int verifiedCount = 0;
    int pendingCount = 0;
    int rejectedCount = 0;
    
    for (var user in users) {
      if (user.kycStatus == 'verified') {
        verifiedCount++;
      } else if (user.kycStatus == 'pending') {
        pendingCount++;
      } else if (user.kycStatus == 'rejected') {
        rejectedCount++;
      }
    }
    
    return {
      'totalUsers': totalCount,
      'verifiedUsers': verifiedCount,
      'pendingVerificationUsers': pendingCount,
      'rejectedUsers': rejectedCount,
    };
  }
  
  // Update mock loan approval/rejection
  Future<bool> approveLoan(String loanId) async {
    if (_devMode) {
      // Find the loan index
      final loanIndex = loans.indexWhere((loan) => loan.id == loanId);
      
      // Check if loan exists
      if (loanIndex >= 0 && loanIndex < loans.length) {
        // Update the loan status in our mock data
        final updatedLoan = LoanModel(
          id: loans[loanIndex].id,
          userId: loans[loanIndex].userId,
          amount: loans[loanIndex].amount,
          emiAmount: loans[loanIndex].emiAmount,
          tenureMonths: loans[loanIndex].tenureMonths,
          interestRate: loans[loanIndex].interestRate,
          status: 'approved',
          applicationDate: loans[loanIndex].applicationDate,
          approvalDate: DateTime.now(),
          dueDate: loans[loanIndex].dueDate,
          paymentDates: loans[loanIndex].paymentDates,
          loanType: loans[loanIndex].loanType,
          purpose: loans[loanIndex].purpose,
          totalInstallments: loans[loanIndex].totalInstallments,
          paidInstallments: loans[loanIndex].paidInstallments,
          amountPaid: loans[loanIndex].amountPaid,
          remainingAmount: loans[loanIndex].remainingAmount,
          startDate: loans[loanIndex].startDate,
          endDate: loans[loanIndex].endDate,
          repayments: loans[loanIndex].repayments,
          userName: loans[loanIndex].userName,
        );
        
        final List<LoanModel> updatedLoans = [...loans];
        updatedLoans[loanIndex] = updatedLoan;
        loans.value = updatedLoans;
        
        // Record admin action
        await _recordAdminAction(
          'loan_approved',
          'Loan $loanId approved for ${updatedLoan.userName}',
        );
        
        print('🔧 Loan approved (dev mode): $loanId');
        return true;
      }
    } else {
      // Implementation for Firebase
      try {
        await _firestore.collection('loans').doc(loanId).update({
          'status': 'approved',
          'approvalDate': DateTime.now().millisecondsSinceEpoch,
        });
        
        // Record admin action
        final loan = loans.firstWhereOrNull((loan) => loan.id == loanId);
        if (loan != null) {
          await _recordAdminAction(
            'loan_approved',
            'Loan $loanId approved for ${loan.userName}',
          );
        } else {
          await _recordAdminAction(
            'loan_approved',
            'Loan $loanId approved',
          );
        }
        
        return true;
      } catch (e) {
        print('Error approving loan: $e');
        return false;
      }
    }
    
    return false;
  }
  
  // Reject a loan
  Future<bool> rejectLoan(String loanId) async {
    if (_devMode) {
      // Find the loan index
      final loanIndex = loans.indexWhere((loan) => loan.id == loanId);
      
      // Check if loan exists
      if (loanIndex >= 0 && loanIndex < loans.length) {
        // Update the loan status in our mock data
        final updatedLoan = LoanModel(
          id: loans[loanIndex].id,
          userId: loans[loanIndex].userId,
          amount: loans[loanIndex].amount,
          emiAmount: loans[loanIndex].emiAmount,
          tenureMonths: loans[loanIndex].tenureMonths,
          interestRate: loans[loanIndex].interestRate,
          status: 'rejected',
          applicationDate: loans[loanIndex].applicationDate,
          approvalDate: loans[loanIndex].approvalDate,
          dueDate: loans[loanIndex].dueDate,
          paymentDates: loans[loanIndex].paymentDates,
          loanType: loans[loanIndex].loanType,
          purpose: loans[loanIndex].purpose,
          totalInstallments: loans[loanIndex].totalInstallments,
          paidInstallments: loans[loanIndex].paidInstallments,
          amountPaid: loans[loanIndex].amountPaid,
          remainingAmount: loans[loanIndex].remainingAmount,
          startDate: loans[loanIndex].startDate,
          endDate: loans[loanIndex].endDate,
          repayments: loans[loanIndex].repayments,
          userName: loans[loanIndex].userName,
        );
        
        final List<LoanModel> updatedLoans = [...loans];
        updatedLoans[loanIndex] = updatedLoan;
        loans.value = updatedLoans;
        
        // Record admin action
        await _recordAdminAction(
          'loan_rejected',
          'Loan $loanId rejected for ${updatedLoan.userName}',
        );
        
        print('🔧 Loan rejected (dev mode): $loanId');
        return true;
      }
    } else {
      // Implementation for Firebase
      try {
        await _firestore.collection('loans').doc(loanId).update({
          'status': 'rejected',
        });
        
        // Record admin action
        final loan = loans.firstWhereOrNull((loan) => loan.id == loanId);
        if (loan != null) {
          await _recordAdminAction(
            'loan_rejected',
            'Loan $loanId rejected for ${loan.userName}',
          );
        } else {
          await _recordAdminAction(
            'loan_rejected',
            'Loan $loanId rejected',
          );
        }
        
        return true;
      } catch (e) {
        print('Error rejecting loan: $e');
        return false;
      }
    }
    
    return false;
  }
} 