import 'package:intl/intl.dart';

class RepaymentModel {
  final String id;
  final double amount;
  final DateTime date;
  final String status;

  RepaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory RepaymentModel.fromMap(Map<String, dynamic> map) {
    return RepaymentModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] is DateTime 
          ? map['date'] 
          : DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      status: map['status'] ?? 'pending',
    );
  }
}

class LoanModel {
  final String id;
  final String userId;
  final double amount;
  final double emiAmount;
  final int tenureMonths;
  final double interestRate;
  final String status;
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final DateTime dueDate;
  final List<DateTime> paymentDates;
  final String loanType;
  final String purpose;
  final int totalInstallments;
  final int paidInstallments;
  final double amountPaid;
  final double remainingAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final List<RepaymentModel> repayments;
  final String userName;
  final double interestAmount;
  final double progressPercentage;

  String get formattedDueDate {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(dueDate);
  }

  bool get isOverdue {
    return dueDate.isBefore(DateTime.now());
  }

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.emiAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.status,
    required this.applicationDate,
    this.approvalDate,
    required this.dueDate,
    List<DateTime>? paymentDates,
    required this.loanType,
    required this.purpose,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.amountPaid,
    required this.remainingAmount,
    required this.startDate,
    this.endDate,
    List<RepaymentModel>? repayments,
    required this.userName,
  }) : 
    this.paymentDates = paymentDates ?? [],
    this.repayments = repayments ?? [],
    this.interestAmount = amount * interestRate / 100 * tenureMonths / 12,
    this.progressPercentage = totalInstallments > 0 
      ? paidInstallments / totalInstallments 
      : 0.0;

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    List<DateTime> paymentDates = [];
    if (map['paymentDates'] != null) {
      paymentDates = (map['paymentDates'] as List).map((item) {
        if (item is DateTime) return item;
        return DateTime.fromMillisecondsSinceEpoch(item);
      }).toList();
    }

    List<RepaymentModel> repayments = [];
    if (map['repayments'] != null) {
      repayments = (map['repayments'] as List).map((item) {
        return RepaymentModel.fromMap(item);
      }).toList();
    }

    return LoanModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      emiAmount: (map['emiAmount'] ?? 0).toDouble(),
      tenureMonths: map['tenureMonths'] ?? 0,
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      applicationDate: map['applicationDate'] is DateTime 
          ? map['applicationDate'] 
          : DateTime.fromMillisecondsSinceEpoch(map['applicationDate'] ?? 0),
      approvalDate: map['approvalDate'] == null 
          ? null 
          : (map['approvalDate'] is DateTime 
              ? map['approvalDate'] 
              : DateTime.fromMillisecondsSinceEpoch(map['approvalDate'])),
      dueDate: map['dueDate'] is DateTime 
          ? map['dueDate'] 
          : DateTime.fromMillisecondsSinceEpoch(map['dueDate'] ?? 0),
      paymentDates: paymentDates,
      loanType: map['loanType'] ?? 'personal',
      purpose: map['purpose'] ?? '',
      totalInstallments: map['totalInstallments'] ?? 0,
      paidInstallments: map['paidInstallments'] ?? 0,
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0).toDouble(),
      startDate: map['startDate'] is DateTime 
          ? map['startDate'] 
          : DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: map['endDate'] == null 
          ? null 
          : (map['endDate'] is DateTime 
              ? map['endDate'] 
              : DateTime.fromMillisecondsSinceEpoch(map['endDate'])),
      repayments: repayments,
      userName: map['userName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'emiAmount': emiAmount,
      'tenureMonths': tenureMonths,
      'interestRate': interestRate,
      'status': status,
      'applicationDate': applicationDate.millisecondsSinceEpoch,
      'approvalDate': approvalDate?.millisecondsSinceEpoch,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'paymentDates': paymentDates.map((date) => date.millisecondsSinceEpoch).toList(),
      'loanType': loanType,
      'purpose': purpose,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'amountPaid': amountPaid,
      'remainingAmount': remainingAmount,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'repayments': repayments.map((repayment) => repayment.toMap()).toList(),
      'userName': userName,
    };
  }
}