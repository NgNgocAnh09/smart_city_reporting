enum IncidentStatus { pending, inProgress, resolved }

class Incident {
  final String? id;
  final String title;
  final String description;
  final String imageUrl;
  final double lat;
  final double lng;
  final IncidentStatus status;
  final String weather;
  final String uid;
  final DateTime createdAt;

  Incident({this.id, required this.title, required this.description, required this.imageUrl, required this.lat, required this.lng, required this.status, required this.weather, required this.uid, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'title': title, 'description': description, 'imageUrl': imageUrl, 'lat': lat, 'lng': lng,
    'status': status.index, 'weather': weather, 'uid': uid, 'createdAt': createdAt.toIso8601String(),
  };

  factory Incident.fromMap(Map<String, dynamic> map, String docId) => Incident(
    id: docId, title: map['title'], description: map['description'], imageUrl: map['imageUrl'],
    lat: map['lat'], lng: map['lng'], status: IncidentStatus.values[map['status']],
    weather: map['weather'], uid: map['uid'], createdAt: DateTime.parse(map['createdAt']),
  );
}