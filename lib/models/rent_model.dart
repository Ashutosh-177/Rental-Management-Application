import 'package:cloud_firestore/cloud_firestore.dart';

enum RentStatus { pending, paid, overdue }

class RentPaymentModel {
  final String id;
  final String propertyId;
  final String roomId;
  final String roomNumber;
  final String tenantId;
  final String tenantName;
  final String ownerId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final RentStatus status;
  final int month; // 1-12
  final int year;
  final String? notes;

  RentPaymentModel({
    required this.id,
    required this.propertyId,
    required this.roomId,
    required this.roomNumber,
    required this.tenantId,
    required this.tenantName,
    required this.ownerId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.status = RentStatus.pending,
    required this.month,
    required this.year,
    this.notes,
  });

  String get monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'ownerId': ownerId,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'status': status.name,
      'month': month,
      'year': year,
      'notes': notes,
    };
  }

  factory RentPaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    return RentPaymentModel(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      dueDate: (map['dueDate'] is Timestamp)
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.parse(map['dueDate']),
      paidDate: map['paidDate'] != null
          ? (map['paidDate'] is Timestamp
              ? (map['paidDate'] as Timestamp).toDate()
              : DateTime.parse(map['paidDate']))
          : null,
      status: RentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RentStatus.pending,
      ),
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      notes: map['notes'],
    );
  }

  RentPaymentModel copyWith({
    RentStatus? status,
    DateTime? paidDate,
    String? notes,
  }) {
    return RentPaymentModel(
      id: id,
      propertyId: propertyId,
      roomId: roomId,
      roomNumber: roomNumber,
      tenantId: tenantId,
      tenantName: tenantName,
      ownerId: ownerId,
      amount: amount,
      dueDate: dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      month: month,
      year: year,
      notes: notes ?? this.notes,
    );
  }
}
