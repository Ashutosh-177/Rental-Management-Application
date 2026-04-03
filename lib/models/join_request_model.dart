enum JoinRequestStatus { pending, approved, rejected }

class JoinRequestModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String tenantId;
  final String tenantName;
  final String tenantPhone;
  final JoinRequestStatus status;
  final DateTime createdAt;

  JoinRequestModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    this.status = JoinRequestStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'propertyName': propertyName,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JoinRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return JoinRequestModel(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      tenantPhone: map['tenantPhone'] ?? '',
      status: JoinRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => JoinRequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
