enum IncidentStatus { pending, inProgress, resolved }

class Incident {
  final String? id;
  final String title;
  final String description;
  final String address;
  final String imageUrl;
  final double lat;
  final double lng;
  final IncidentStatus status;
  final String uid;
  final DateTime createdAt;

  Incident({this.id, required this.title, required this.description,required this.address, required this.imageUrl, required this.lat, required this.lng, required this.status, required this.uid, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'title': title, 'description': description, 'address': address, 'imageUrl': imageUrl, 'lat': lat, 'lng': lng,
    'status': status.index, 'uid': uid, 'createdAt': createdAt.toIso8601String(),
  };

  factory Incident.fromMap(Map<String, dynamic> map, String id) {
    return Incident(
      id: id,
      // CHÚ Ý: Phải có ?? '' ở tất cả các dòng này
      title: map['title'] ?? 'Không có tiêu đề',
      description: map['description'] ?? '',
      address: map['address'] ?? 'Chưa có địa chỉ', // Dòng này quan trọng nhất
      imageUrl: map['imageUrl'] ?? '',
      uid: map['uid'] ?? '',
      
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => IncidentStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}