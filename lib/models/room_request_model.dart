class RoomRequestModel {
  final String id;
  final String tenantId;
  final String tenantName;
  final String propertyId;
  final String roomId;
  final String roomNumber;
  final String status; // pending, approved, rejected
  final DateTime timestamp;

  RoomRequestModel({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.propertyId,
    required this.roomId,
    required this.roomNumber,
    this.status = 'pending',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'propertyId': propertyId,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RoomRequestModel.fromMap(Map<String, dynamic> map) {
    return RoomRequestModel(
      id: map['id'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
