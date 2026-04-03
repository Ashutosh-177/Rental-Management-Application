enum MaintenanceStatus { pending, inProgress, resolved }

class MaintenanceRequestModel {
  final String id;
  final String propertyId;
  final String roomId;
  final String tenantId;
  final String tenantName;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final String? imageUrl;
  final DateTime createdAt;
  final String ownerId;

  MaintenanceRequestModel({
    required this.id,
    required this.propertyId,
    required this.roomId,
    required this.tenantId,
    required this.tenantName,
    required this.title,
    required this.description,
    this.status = MaintenanceStatus.pending,
    this.imageUrl,
    required this.createdAt,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'roomId': roomId,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'title': title,
      'description': description,
      'status': status.name,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
    };
  }

  factory MaintenanceRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return MaintenanceRequestModel(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      roomId: map['roomId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      ownerId: map['ownerId'] ?? '',
    );
  }

  MaintenanceRequestModel copyWith({
    String? id,
    String? imageUrl,
    MaintenanceStatus? status,
  }) {
    return MaintenanceRequestModel(
      id: id ?? this.id,
      propertyId: propertyId,
      roomId: roomId,
      tenantId: tenantId,
      tenantName: tenantName,
      title: title,
      description: description,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}
