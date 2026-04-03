import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/rent_model.dart';

class RentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate rent records for ALL tenants in a property for a given month/year.
  // Skips tenants who already have a record for that period.
  Future<String?> generateRentForProperty({
    required String propertyId,
    required String ownerId,
    required int month,
    required int year,
  }) async {
    try {
      // Fetch all rooms in the property
      final roomsSnap = await _firestore
          .collection('properties')
          .doc(propertyId)
          .collection('rooms')
          .get();

      for (final roomDoc in roomsSnap.docs) {
        final roomData = roomDoc.data();
        final roomId = roomDoc.id;
        final roomNumber = roomData['roomNumber'] ?? '';
        final rentAmount = (roomData['rentAmount'] ?? 0.0).toDouble();

        // Fetch all tenants assigned to this room
        final tenantsSnap = await _firestore
            .collection('properties')
            .doc(propertyId)
            .collection('tenants')
            .where('roomId', isEqualTo: roomId)
            .get();

        for (final tenantDoc in tenantsSnap.docs) {
          final tenantData = tenantDoc.data();
          final tenantId = tenantDoc.id;
          final tenantName = tenantData['name'] ?? '';

          // Check if record already exists for this tenant/month/year
          final existing = await _firestore
              .collection('rent_payments')
              .where('tenantId', isEqualTo: tenantId)
              .where('month', isEqualTo: month)
              .where('year', isEqualTo: year)
              .get();

          if (existing.docs.isNotEmpty) continue;

          // Due date = 5th of the given month
          final dueDate = DateTime(year, month, 5);

          // Determine status: if dueDate is in the past and unpaid → overdue
          final status = dueDate.isBefore(DateTime.now())
              ? RentStatus.overdue
              : RentStatus.pending;

          final record = RentPaymentModel(
            id: '',
            propertyId: propertyId,
            roomId: roomId,
            roomNumber: roomNumber,
            tenantId: tenantId,
            tenantName: tenantName,
            ownerId: ownerId,
            amount: rentAmount,
            dueDate: dueDate,
            status: status,
            month: month,
            year: year,
          );

          await _firestore.collection('rent_payments').add(record.toMap());
        }
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Mark a rent record as paid
  Future<String?> markAsPaid(String rentId, {String? notes}) async {
    try {
      await _firestore.collection('rent_payments').doc(rentId).update({
        'status': RentStatus.paid.name,
        'paidDate': Timestamp.fromDate(DateTime.now()),
        if (notes != null) 'notes': notes,
      });

      // Notify tenant
      final doc = await _firestore.collection('rent_payments').doc(rentId).get();
      final tenantId = doc.data()?['tenantId'];
      final monthLabel = _monthLabel(doc.data()?['month'], doc.data()?['year']);

      if (tenantId != null) {
        await _firestore.collection('notifications').add({
          'userId': tenantId,
          'title': 'Rent Received',
          'message': 'Your rent for $monthLabel has been marked as paid.',
          'type': 'rent_paid',
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Send a payment reminder notification to a tenant
  Future<void> sendRentReminder(String rentId) async {
    final doc = await _firestore.collection('rent_payments').doc(rentId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final tenantId = data['tenantId'];
    final monthLabel = _monthLabel(data['month'], data['year']);
    final amount = data['amount'];

    await _firestore.collection('notifications').add({
      'userId': tenantId,
      'title': 'Rent Reminder',
      'message': 'Your rent of ₹$amount for $monthLabel is due. Please pay on time.',
      'type': 'rent_reminder',
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': false,
    });
  }

  // Stream: all rent records for a property in a given month/year (Owner view)
  Stream<List<RentPaymentModel>> getRentStreamForProperty({
    required String propertyId,
    required int month,
    required int year,
  }) {
    return _firestore
        .collection('rent_payments')
        .where('propertyId', isEqualTo: propertyId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RentPaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream: all rent records for an owner (across all properties)
  Stream<List<RentPaymentModel>> getRentStreamForOwner({
    required String ownerId,
    required int month,
    required int year,
  }) {
    return _firestore
        .collection('rent_payments')
        .where('ownerId', isEqualTo: ownerId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RentPaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream: a tenant's rent history (latest first)
  Stream<List<RentPaymentModel>> getRentHistoryForTenant(String tenantId) {
    return _firestore
        .collection('rent_payments')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RentPaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream: tenant's current month rent record
  Stream<RentPaymentModel?> getCurrentRentForTenant(String tenantId) {
    final now = DateTime.now();
    return _firestore
        .collection('rent_payments')
        .where('tenantId', isEqualTo: tenantId)
        .where('month', isEqualTo: now.month)
        .where('year', isEqualTo: now.year)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : RentPaymentModel.fromMap(snap.docs.first.data(), snap.docs.first.id));
  }

  String _monthLabel(int? month, int? year) {
    if (month == null || year == null) return '';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }
}
