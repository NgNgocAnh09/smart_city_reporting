import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Thư viện tọa độ mới dùng cho OSM
import 'package:url_launcher/url_launcher.dart';

import '../../models/incident_model.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // NHẬN DỮ LIỆU
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is! Incident) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sự cố')),
        body: const Center(child: Text('Lỗi: Dữ liệu điều hướng không hợp lệ.')),
      );
    }

    final incident = args;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sự cố')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(incident: incident),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _StatusChip(status: incident.status),
                  const SizedBox(height: 16),
                  Text(incident.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place, size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          incident.address.isNotEmpty ? incident.address : 'Chưa có địa chỉ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const Text('Vị trí sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  // BẢN ĐỒ OPENSTREETMAP NẰM Ở ĐÂY
                  _MiniMap(incident: incident),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openDirections(incident.lat, incident.lng),
                      icon: const Icon(Icons.directions),
                      label: const Text('Chỉ đường'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mở ứng dụng bản đồ trên điện thoại (Google Maps hoặc Apple Maps) để dẫn đường
  Future<void> _openDirections(double lat, double lng) async {
    final String url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final Uri uri = Uri.parse(url);
    try{

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Không thể mở ứng dụng chỉ đường.');
    }
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'incident-image-${incident.id ?? incident.imageUrl}',
      child: incident.imageUrl.isEmpty 
        ? Container(height: 240, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50))
        : Image.network(incident.imageUrl, width: double.infinity, height: 240, fit: BoxFit.cover),
    );
  }
}

// =====================================================================
// COMPONENT BẢN ĐỒ SỬ DỤNG OPENSTREETMAP
// =====================================================================
class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    // Tọa độ điểm ghim
    final point = LatLng(incident.lat, incident.lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point, // Căn giữa bản đồ vào tọa độ sự cố
            initialZoom: 15.0,    // Độ zoom mặc định
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Khóa tương tác (chỉ để xem tĩnh giống liteMode)
            ),
          ),
          children: [
            // Lớp nền bản đồ tải từ server của OpenStreetMap miễn phí
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.smart_city_reporting',
            ),
            // Lớp ghim (Marker)
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      IncidentStatus.pending => ('Chờ xử lý', Colors.orange),
      IncidentStatus.inProgress => ('Đang xử lý', Colors.blue),
      IncidentStatus.resolved => ('Đã xử lý', Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}