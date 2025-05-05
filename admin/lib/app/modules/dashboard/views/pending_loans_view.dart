import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/user_model.dart';

class PendingLoansView extends GetView<DashboardController> {
  PendingLoansView({Key? key}) : super(key: key);

  // State variables
  final RxString _selectedSortOption = 'newest'.obs;
  final RxList<LoanModel> _pendingLoans = <LoanModel>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadData();
              _updatePendingLoans();
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
            : _buildBody(),
      ),
    );
  }

  void _updatePendingLoans() {
    _pendingLoans.value = controller.loans
        .where((loan) => loan.status == 'pending')
        .toList();
    _applySorting();
  }

  void _applySorting() {
    switch (_selectedSortOption.value) {
      case 'newest':
        _pendingLoans.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        break;
      case 'oldest':
        _pendingLoans.sort((a, b) => a.applicationDate.compareTo(b.applicationDate));
        break;
      case 'amount_high':
        _pendingLoans.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        _pendingLoans.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
  }

  Widget _buildBody() {
    // Update pending loans if needed
    if (_pendingLoans.isEmpty && controller.loans.isNotEmpty) {
      _updatePendingLoans();
    }

    // Show empty state if no pending loans
    if (_pendingLoans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 72,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending loan applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All loan applications have been processed',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Show pending loans list
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Approval Guidelines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review user KYC, verify loan eligibility, and check repayment capability before approving loans.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showGuidelinesDialog(Get.context!);
                    },
                    child: const Text('View Guidelines'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_pendingLoans.length} pending approval${_pendingLoans.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Obx(() => DropdownButton<String>(
                value: _selectedSortOption.value,
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                  DropdownMenuItem(value: 'amount_high', child: Text('Amount (High to Low)')),
                  DropdownMenuItem(value: 'amount_low', child: Text('Amount (Low to High)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedSortOption.value = value;
                    _applySorting();
                  }
                },
              )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pendingLoans.length,
            itemBuilder: (context, index) {
              if (index >= 0 && index < _pendingLoans.length) {
                final loan = _pendingLoans[index];
                final user = controller.getUserById(loan.userId);
                return _buildPendingLoanCard(context, loan, user);
              }
              return const SizedBox.shrink();
            },
          )),
        ),
      ],
    );
  }

  Widget _buildPendingLoanCard(BuildContext context, LoanModel loan, UserModel? user) {
    final loanTypeColor = _getLoanTypeColor(loan.loanType);
    final loanTypeIcon = _getLoanTypeIcon(loan.loanType);
    final daysElapsed = DateTime.now().difference(loan.applicationDate).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(loanTypeIcon, color: loanTypeColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  loan.loanType.replaceAll('_', ' ').capitalize!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: loanTypeColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Applied ${daysElapsed > 0 ? '$daysElapsed day${daysElapsed > 1 ? 's' : ''} ago' : 'today'}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan #${loan.id.length > 8 ? loan.id.substring(0, 8) : loan.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Applicant: ${user?.fullName ?? 'Unknown User'}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${loan.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loan.tenureMonths} months @ ${loan.interestRate}%',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLoanDetail('Purpose', loan.purpose),
                    _buildLoanDetail('EMI', '₹${loan.emiAmount.toStringAsFixed(0)}/month'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLoanDetail('KYC Status', user?.kycStatus.toUpperCase() ?? 'UNKNOWN'),
                    _buildLoanDetail('User Since', 
                      user != null ? 
                        user.createdAt != null ? 
                          user.createdAt.toString().substring(0, 
                            user.createdAt.toString().length >= 10 ? 10 : user.createdAt.toString().length) 
                          : 'N/A' 
                        : 'Unknown'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showLoanDetailsDialog(context, loan, user),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(context, loan, user, approve: true),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(context, loan, user, approve: false),
                          icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
            overflow: TextOverflow.ellipsis,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loan Details',
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
                      child: _buildInfoRow('Purpose', loan.purpose),
                    ),
                    Expanded(
                      child: _buildInfoRow('Application Date', 
                        loan.applicationDate != null ? 
                          loan.applicationDate.toString().substring(0, 
                            loan.applicationDate.toString().length >= 10 ? 10 : loan.applicationDate.toString().length) 
                          : 'N/A'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Applicant Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow('Name', user.fullName),
                      ),
                      Expanded(
                        child: _buildInfoRow('Email', user.email),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow('Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not provided'),
                      ),
                      Expanded(
                        child: _buildInfoRow('KYC Status', user.kycStatus.toUpperCase()),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow('Address', 
                          [user.address, user.city, user.state, user.zipCode]
                              .where((s) => s.isNotEmpty)
                              .join(', ')),
                      ),
                      Expanded(
                        child: _buildInfoRow('User Since', 
                          user.createdAt != null ? 
                            user.createdAt.toString().substring(0, 
                              user.createdAt.toString().length >= 10 ? 10 : user.createdAt.toString().length) 
                            : 'N/A'),
                      ),
                    ],
                  ),
                  if (user.kycDocumentUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'KYC Document',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Open document in full screen
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        alignment: Alignment.center,
                        child: Image.network(
                          user.kycDocumentUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Unable to load document',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  const Text(
                    'User information not available',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Repayment Calculation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Principal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '₹${loan.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Interest (${loan.interestRate}% for ${loan.tenureMonths} months)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '₹${loan.interestAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total Repayment',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '₹${(loan.amount + loan.interestAmount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Monthly EMI (${loan.totalInstallments} installments)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '₹${loan.emiAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showApprovalDialog(context, loan, user, approve: true);
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
                            _showApprovalDialog(context, loan, user, approve: false);
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

  void _showApprovalDialog(BuildContext context, LoanModel loan, UserModel? user, {required bool approve}) {
    final TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            approve ? 'Approve Loan Application' : 'Reject Loan Application',
            style: TextStyle(
              color: approve ? Colors.green : Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                approve
                    ? 'Are you sure you want to approve this loan application?'
                    : 'Are you sure you want to reject this loan application?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: approve ? 'Approval Note (Optional)' : 'Rejection Reason (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                if (approve) {
                  controller.approveLoan(loan.id);
                } else {
                  controller.rejectLoan(loan.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(approve ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showGuidelinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Approval Guidelines',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 24),
                _buildGuidelineItem(
                  'User Verification',
                  'Ensure the user\'s KYC documents are verified and authentic.',
                  Icons.verified_user,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildGuidelineItem(
                  'Eligibility Check',
                  'Verify that the loan amount and tenure align with the user\'s profile and loan limits.',
                  Icons.rule,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildGuidelineItem(
                  'Repayment Capacity',
                  'Assess if the user has the capacity to repay the loan based on their profile.',
                  Icons.payments,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildGuidelineItem(
                  'Risk Assessment',
                  'Consider any potential risks associated with the loan application.',
                  Icons.shield,
                  Colors.red,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got It'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidelineItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Color _getLoanTypeColor(String loanType) {
    switch (loanType) {
      case 'personal':
        return Colors.blue;
      case 'business':
        return Colors.purple;
      case 'quick_cash':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
} 