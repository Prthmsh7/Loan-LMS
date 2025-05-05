import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/user_model.dart';

class LoansView extends GetView<DashboardController> {
  LoansView({Key? key}) : super(key: key);

  // Search and filtering state
  final TextEditingController _searchController = TextEditingController();
  final RxString _selectedLoanStatus = 'all'.obs;
  final RxString _selectedLoanType = 'all'.obs;
  final RxString _selectedSortOption = 'newest'.obs;
  final RxList<LoanModel> _filteredLoans = <LoanModel>[].obs;

  @override
  Widget build(BuildContext context) {
    // Initialize filtered loans with all loans
    if (_filteredLoans.isEmpty && controller.loans.isNotEmpty) {
      _filteredLoans.value = controller.loans;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadData();
              _filteredLoans.value = controller.loans;
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Dashboard',
            onPressed: () => Get.offNamed('/dashboard'),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: Obx(() => 
            _filteredLoans.isEmpty
                ? Center(
                    child: Text(
                      'No loans found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredLoans.length,
                    itemBuilder: (context, index) {
                      if (index >= 0 && index < _filteredLoans.length) {
                        final loan = _filteredLoans[index];
                        final user = controller.getUserById(loan.userId);
                        return _buildLoanCard(context, loan, user);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search loans by ID or user name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              ),
            ),
            onChanged: (value) {
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Loan Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  value: _selectedLoanStatus.value,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedLoanStatus.value = value;
                      _applyFilters();
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Loan Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  value: _selectedLoanType.value,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'personal', child: Text('Personal')),
                    DropdownMenuItem(value: 'business', child: Text('Business')),
                    DropdownMenuItem(value: 'quick_cash', child: Text('Quick Cash')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedLoanType.value = value;
                      _applyFilters();
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  value: _selectedSortOption.value,
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                    DropdownMenuItem(value: 'amount_high', child: Text('Amount (High to Low)')),
                    DropdownMenuItem(value: 'amount_low', child: Text('Amount (Low to High)')),
                    DropdownMenuItem(value: 'due_date', child: Text('Due Date')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedSortOption.value = value;
                      _applyFilters();
                    }
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Step 1: Filter by loan status
    List<LoanModel> result = controller.loans;
    
    if (_selectedLoanStatus.value != 'all') {
      result = result.where((loan) => loan.status == _selectedLoanStatus.value).toList();
    }
    
    // Step 2: Filter by loan type
    if (_selectedLoanType.value != 'all') {
      result = result.where((loan) => loan.loanType == _selectedLoanType.value).toList();
    }
    
    // Step 3: Apply search
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      result = result.where((loan) {
        final user = controller.getUserById(loan.userId);
        return loan.id.toLowerCase().contains(lowercaseQuery) ||
               (user != null && user.fullName.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }
    
    // Step 4: Apply sorting
    switch (_selectedSortOption.value) {
      case 'newest':
        result.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        break;
      case 'oldest':
        result.sort((a, b) => a.applicationDate.compareTo(b.applicationDate));
        break;
      case 'amount_high':
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'due_date':
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
    }
    
    // Update filtered loans
    _filteredLoans.value = result;
  }

  Widget _buildLoanCard(BuildContext context, LoanModel loan, UserModel? user) {
    Color statusColor;
    IconData statusIcon;

    switch (loan.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'closed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 70,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Loan #${loan.id.length > 8 ? loan.id.substring(0, 8) : loan.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Chip(
                            label: Text(
                              loan.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: statusColor,
                            avatar: Icon(
                              statusIcon,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Applicant',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.fullName ?? 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${loan.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLoanDetail('Loan Type', loan.loanType.replaceAll('_', ' ').capitalize!),
                _buildLoanDetail('Duration', '${loan.tenureMonths} months'),
                _buildLoanDetail('Interest', '${loan.interestRate}%'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLoanDetail('Applied On', 
                  loan.applicationDate != null ? 
                    loan.applicationDate.toString().substring(0, 
                      loan.applicationDate.toString().length >= 10 ? 10 : loan.applicationDate.toString().length) 
                    : 'N/A'),
                _buildLoanDetail('Due Date', 
                  loan.dueDate != null ? 
                    loan.dueDate.toString().substring(0, 
                      loan.dueDate.toString().length >= 10 ? 10 : loan.dueDate.toString().length) 
                    : 'N/A'),
                _buildLoanDetail('EMI Amount', '₹${loan.emiAmount.toStringAsFixed(2)}'),
              ],
            ),
            if (loan.status == 'approved') ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: loan.progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repayment Progress: ${(loan.progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${loan.paidInstallments}/${loan.totalInstallments} installments',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showLoanDetailsDialog(context, loan, user),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details'),
                ),
                if (loan.status == 'pending')
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => controller.approveLoan(loan.id),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                        label: const Text('Approve', style: TextStyle(color: Colors.green)),
                      ),
                      TextButton.icon(
                        onPressed: () => controller.rejectLoan(loan.id),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoanDetailsDialog(BuildContext context, LoanModel loan, UserModel? user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getLoanTypeIcon(loan.loanType),
                      size: 32,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan #${loan.id.length > 8 ? loan.id.substring(0, 8) : loan.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loan.loanType.replaceAll('_', ' ').capitalize!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        loan.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(loan.status),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loan Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Principal Amount', '₹${loan.amount.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Interest Rate', '${loan.interestRate.toStringAsFixed(2)}%'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Tenure', '${loan.tenureMonths} months'),
                    ),
                    Expanded(
                      child: _buildInfoRow('EMI Amount', '₹${loan.emiAmount.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Total Interest', '₹${loan.interestAmount.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Total Amount', '₹${(loan.amount + loan.interestAmount).toStringAsFixed(2)}'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Timeline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Application Date', 
                        loan.applicationDate != null ? 
                          loan.applicationDate.toString().substring(0, 
                            loan.applicationDate.toString().length >= 10 ? 10 : loan.applicationDate.toString().length) 
                          : 'N/A'),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        'Approval Date',
                        loan.approvalDate != null ? 
                          loan.approvalDate.toString().substring(0, 
                            loan.approvalDate.toString().length >= 10 ? 10 : loan.approvalDate.toString().length) 
                          : 'N/A',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Start Date', 
                        loan.startDate != null ? 
                          loan.startDate.toString().substring(0, 
                            loan.startDate.toString().length >= 10 ? 10 : loan.startDate.toString().length) 
                          : 'N/A'),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        'End Date',
                        loan.endDate != null ? 
                          loan.endDate.toString().substring(0, 
                            loan.endDate.toString().length >= 10 ? 10 : loan.endDate.toString().length) 
                          : 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Repayment Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Installments Paid', '${loan.paidInstallments}/${loan.totalInstallments}'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Amount Paid', '₹${loan.amountPaid.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Remaining Amount', '₹${loan.remainingAmount.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Next Due Date', loan.formattedDueDate),
                    ),
                  ],
                ),
                if (loan.status == 'approved') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Repayment Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: loan.progressPercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(loan.progressPercentage * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Applicant Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Name', user?.fullName ?? 'Unknown'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Email', user?.email ?? 'N/A'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Phone', user?.phoneNumber ?? 'N/A'),
                    ),
                    Expanded(
                      child: _buildInfoRow('KYC Status', user?.kycStatus.toUpperCase() ?? 'N/A'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    if (loan.status == 'pending')
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              controller.approveLoan(loan.id);
                            },
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                            label: const Text('Approve Loan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              controller.rejectLoan(loan.id);
                            },
                            icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                            label: const Text('Reject Loan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLoanTypeIcon(String loanType) {
    switch (loanType) {
      case 'personal':
        return Icons.person;
      case 'business':
        return Icons.business;
      case 'quick_cash':
        return Icons.flash_on;
      default:
        return Icons.attach_money;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'closed':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
} 