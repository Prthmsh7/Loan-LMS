import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'sync_service.dart';

class LoanService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  // Get access to the sync service
  late SyncService _syncService;

  // Observable lists
  final RxList<LoanModel> _loans = <LoanModel>[].obs;
  final RxList<LoanModel> _pendingLoans = <LoanModel>[].obs;
  final RxMap<String, int> _loanStatusCounts = <String, int>{}.obs;
  final RxDouble _totalAmountLent = 0.0.obs;
  final RxDouble _totalAmountRepaid = 0.0.obs;

  // Getters
  List<LoanModel> get loans => _loans;
  List<LoanModel> get pendingLoans => _pendingLoans;
  Map<String, int> get loanStatusCounts => _loanStatusCounts;
  double get totalAmountLent => _totalAmountLent.value;
  double get totalAmountRepaid => _totalAmountRepaid.value;

  // Initialize service
  Future<LoanService> init() async {
    print('LoanService initialized');
    
    try {
      // Get the sync service
      _syncService = Get.find<SyncService>();
      
      // Set up a listener for changes from the sync service
      ever(_syncService.loans, _onLoansUpdated);
      
      // Fetch initial data
      if (_syncService.loans.isNotEmpty) {
        _onLoansUpdated(_syncService.loans);
      } else {
        await fetchLoans();
      }
    } catch (e) {
      print('Error connecting to SyncService: $e');
      // If SyncService fails, try to get data directly
      await fetchLoans();
    }
    
    return this;
  }

  @override
  void onInit() {
    super.onInit();
  }
  
  // Handler for when loans are updated through SyncService
  void _onLoansUpdated(List<LoanModel> updatedLoans) {
    _loans.value = updatedLoans;
    _pendingLoans.value = updatedLoans.where((l) => l.status == 'pending').toList();
    
    // Update statistics
    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;
    int closedCount = 0;
    double totalLent = 0.0;
    double totalRepaid = 0.0;
    
    for (var loan in updatedLoans) {
      switch (loan.status) {
        case 'pending':
          pendingCount++;
          break;
        case 'approved':
          approvedCount++;
          totalLent += loan.amount;
          totalRepaid += loan.amountPaid;
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
    
    _loanStatusCounts.value = {
      'pending': pendingCount,
      'approved': approvedCount,
      'rejected': rejectedCount,
      'closed': closedCount,
    };
    
    _totalAmountLent.value = totalLent;
    _totalAmountRepaid.value = totalRepaid;
    
    print('Loans updated from SyncService: ${_loans.length} loans');
  }

  // Fetch all loans from Firestore
  Future<void> fetchLoans() async {
    try {
      final snapshot = await _firestore.collection('loans').get();
      
      final List<LoanModel> loadedLoans = [];
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int closedCount = 0;
      double totalLent = 0.0;
      double totalRepaid = 0.0;
      
      for (var doc in snapshot.docs) {
        final loanData = doc.data();
        final loan = LoanModel.fromMap({
          'id': doc.id,
          ...loanData,
        });
        
        loadedLoans.add(loan);
        
        // Update status counts
        switch (loan.status) {
          case 'pending':
            pendingCount++;
            break;
          case 'approved':
            approvedCount++;
            totalLent += loan.amount;
            totalRepaid += loan.amountPaid;
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
      
      // Update observable collections
      _loans.value = loadedLoans;
      _pendingLoans.value = loadedLoans.where((l) => l.status == 'pending').toList();
      
      // Update statistics
      _loanStatusCounts.value = {
        'pending': pendingCount,
        'approved': approvedCount,
        'rejected': rejectedCount,
        'closed': closedCount,
      };
      
      _totalAmountLent.value = totalLent;
      _totalAmountRepaid.value = totalRepaid;
      
    } catch (e) {
      print('Error fetching loans: $e');
    }
  }

  // Generate sample loans for development
  void _generateSampleLoans() {
    final now = DateTime.now();
    
    final sampleLoans = [
      LoanModel(
        id: '1',
        amount: 50000,
        emiAmount: 5000,
        tenureMonths: 12,
        interestRate: 10.5,
        status: 'approved',
        applicationDate: now.subtract(const Duration(days: 30)),
        approvalDate: now.subtract(const Duration(days: 28)),
        dueDate: now.add(const Duration(days: 3)),
        paymentDates: [
          now.subtract(const Duration(days: 27)),
        ],
        userId: 'user1',
        loanType: 'personal',
        purpose: 'Home Renovation',
        totalInstallments: 12,
        paidInstallments: 1,
        amountPaid: 5000,
        remainingAmount: 45000,
        startDate: now.subtract(const Duration(days: 28)),
        endDate: now.add(const Duration(days: 332)),
        repayments: [
          RepaymentModel(
            id: 'repay1',
            amount: 5000,
            date: now.subtract(const Duration(days: 27)),
            status: 'paid',
          ),
        ],
        userName: 'John Doe',
      ),
      LoanModel(
        id: '2',
        amount: 15000,
        emiAmount: 5250,
        tenureMonths: 3,
        interestRate: 12.0,
        status: 'pending',
        applicationDate: now.subtract(const Duration(days: 2)),
        approvalDate: null,
        dueDate: now.add(const Duration(days: 28)),
        paymentDates: [],
        userId: 'user2',
        loanType: 'quick_cash',
        purpose: 'Emergency Expenses',
        totalInstallments: 3,
        paidInstallments: 0,
        amountPaid: 0,
        remainingAmount: 15000,
        startDate: now,
        repayments: [],
        userName: 'Jane Smith',
      ),
    ];
    
    _loans.value = sampleLoans;
    _pendingLoans.value = sampleLoans.where((l) => l.status == 'pending').toList();
    
    // Update statistics
    _loanStatusCounts.value = {
      'pending': 1,
      'approved': 1,
      'rejected': 0,
      'closed': 0,
    };
    
    _totalAmountLent.value = 50000;
    _totalAmountRepaid.value = 5000;
  }

  // Get loans for a specific user
  Future<List<LoanModel>> getUserLoans(String userId) async {
    try {
      // Check if we have data in SyncService
      if (_syncService.loans.isNotEmpty) {
        return _syncService.loans.where((loan) => loan.userId == userId).toList();
      }
      
      // Fallback to direct Firebase query
      final snapshot = await _firestore
          .collection('loans')
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.map((doc) {
        return LoanModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error fetching user loans: $e');
      return [];
    }
  }

  // Get a specific loan by ID
  Future<LoanModel?> getLoanById(String loanId) async {
    try {
      // Check if we have the loan in SyncService
      final syncLoan = _syncService.loans.firstWhereOrNull((loan) => loan.id == loanId);
      if (syncLoan != null) {
        return syncLoan;
      }
      
      // Fallback to direct Firebase query
      final doc = await _firestore.collection('loans').doc(loanId).get();
      
      if (doc.exists) {
        return LoanModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      
      return null;
    } catch (e) {
      print('Error fetching loan: $e');
      return null;
    }
  }

  // Approve a loan
  Future<bool> approveLoan(String loanId) async {
    try {
      // Use SyncService to update the loan status
      bool success = await _syncService.updateLoanStatus(loanId, 'approved');
      
      if (success) {
        // Refresh loans
        await fetchLoans();
      }
      
      return success;
    } catch (e) {
      print('Error approving loan: $e');
      
      // Fallback to direct Firebase update
      try {
        final now = DateTime.now();
        
        await _firestore.collection('loans').doc(loanId).update({
          'status': 'approved',
          'approvalDate': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        });
        
        // Refresh loans
        await fetchLoans();
        
        return true;
      } catch (fallbackError) {
        print('Fallback error approving loan: $fallbackError');
        return false;
      }
    }
  }

  // Reject a loan
  Future<bool> rejectLoan(String loanId, {String reason = 'Application rejected by admin'}) async {
    try {
      // Use SyncService to update the loan status
      bool success = await _syncService.updateLoanStatus(loanId, 'rejected', rejectionReason: reason);
      
      if (success) {
        // Refresh loans
        await fetchLoans();
      }
      
      return success;
    } catch (e) {
      print('Error rejecting loan: $e');
      
      // Fallback to direct Firebase update
      try {
        final now = DateTime.now();
        
        await _firestore.collection('loans').doc(loanId).update({
          'status': 'rejected',
          'rejectionReason': reason,
          'updatedAt': now.millisecondsSinceEpoch,
        });
        
        // Refresh loans
        await fetchLoans();
        
        return true;
      } catch (fallbackError) {
        print('Fallback error rejecting loan: $fallbackError');
        return false;
      }
    }
  }

  // Get loan statistics 
  Map<String, dynamic> getLoanStatistics() {
    // Try to use SyncService statistics first
    try {
      return _syncService.getLoanStatistics();
    } catch (e) {
      print('Error getting statistics from SyncService: $e');
      
      // Fallback to calculating statistics locally
      double totalInterestEarned = 0;
      int activeLoans = 0;
      
      for (var loan in _loans) {
        if (loan.status == 'approved') {
          activeLoans++;
          final interestPaid = loan.amountPaid - (loan.amount / loan.totalInstallments * loan.paidInstallments);
          if (interestPaid > 0) {
            totalInterestEarned += interestPaid;
          }
        }
      }
      
      return {
        'totalAmountLent': _totalAmountLent.value,
        'totalAmountRepaid': _totalAmountRepaid.value,
        'totalInterestEarned': totalInterestEarned,
        'activeLoans': activeLoans,
        'pendingLoans': _loanStatusCounts['pending'] ?? 0,
        'completedLoans': _loanStatusCounts['closed'] ?? 0,
        'rejectedLoans': _loanStatusCounts['rejected'] ?? 0,
      };
    }
  }
} 