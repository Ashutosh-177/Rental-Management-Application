enum IdentityStatus { pending, verified, rejected }
enum IdentityType { aadhaar, pan, license, voterId }

class IdentityModel {
  final String userId;
  final IdentityType docType;
  final String fileUrl;
  final IdentityStatus status;
  final DateTime uploadedAt;
  final String? rejectionReason;

  IdentityModel({
    required this.userId,
    required this.docType,
    required this.fileUrl,
    this.status = IdentityStatus.pending,
    required this.uploadedAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'docType': docType.name,
      'fileUrl': fileUrl,
      'status': status.name,
      'uploadedAt': uploadedAt.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory IdentityModel.fromMap(Map<String, dynamic> map) {
    return IdentityModel(
      userId: map['userId'] ?? '',
      docType: IdentityType.values.firstWhere((e) => e.name == map['docType']),
      fileUrl: map['fileUrl'] ?? '',
      status: IdentityStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => IdentityStatus.pending),
      uploadedAt: DateTime.parse(map['uploadedAt'] ?? DateTime.now().toIso8601String()),
      rejectionReason: map['rejectionReason'],
    );
  }
}
