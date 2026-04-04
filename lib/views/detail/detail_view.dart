import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/incident_model.dart';
import '../../providers/incident_provider.dart';
import 'widgets/weather_card.dart';

class DetailView extends StatelessWidget {
	const DetailView({super.key});

	@override
	Widget build(BuildContext context) {
		final args = ModalRoute.of(context)!.settings.arguments;
		final incidentProvider = context.watch<IncidentProvider>();

		if (args is! String) {
			return Scaffold(
				appBar: AppBar(title: const Text('Chi tiet su co')),
				body: const Center(child: Text('Du lieu dieu huong khong hop le.')),
			);
		}

		final incident = incidentProvider.getIncidentById(args);

		if (incident == null) {
			return Scaffold(
				appBar: AppBar(title: const Text('Chi tiet su co')),
				body: const Center(child: Text('Khong tim thay du lieu su co.')),
			);
		}

		return Scaffold(
			appBar: AppBar(title: const Text('Chi tiet su co')),
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
									Text(
										incident.description,
										style: Theme.of(context).textTheme.bodyLarge,
									),
									const SizedBox(height: 16),
									WeatherCard(weatherText: incident.weather),
									const SizedBox(height: 16),
									Text(
										'Vi tri su co',
										style: Theme.of(context).textTheme.titleMedium?.copyWith(
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 8),
									_MiniMap(incident: incident),
									const SizedBox(height: 12),
									SizedBox(
										width: double.infinity,
										child: FilledButton.icon(
											onPressed: () => _openDirections(incident.lat, incident.lng),
											icon: const Icon(Icons.directions),
											label: const Text('Chi duong'),
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

	Future<void> _openDirections(double lat, double lng) async {
		final uri = Uri.parse(
			'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
		);
		await launchUrl(uri, mode: LaunchMode.externalApplication);
	}
}

class _HeroImage extends StatelessWidget {
	const _HeroImage({required this.incident});

	final Incident incident;

	@override
	Widget build(BuildContext context) {
		final heroTag = 'incident-image-${incident.id ?? incident.imageUrl}';

		if (incident.imageUrl.trim().isEmpty) {
			return Container(
				height: 240,
				width: double.infinity,
				color: Theme.of(context).colorScheme.surfaceContainerHighest,
				child: const Icon(Icons.image_not_supported_outlined, size: 44),
			);
		}

		return Hero(
			tag: heroTag,
			child: Image.network(
				incident.imageUrl,
				width: double.infinity,
				height: 240,
				fit: BoxFit.cover,
				errorBuilder: (context, error, stackTrace) {
					return Container(
						height: 240,
						width: double.infinity,
						color: Theme.of(context).colorScheme.surfaceContainerHighest,
						child: const Icon(Icons.broken_image_outlined, size: 44),
					);
				},
			),
		);
	}
}

class _MiniMap extends StatelessWidget {
	const _MiniMap({required this.incident});

	final Incident incident;

	@override
	Widget build(BuildContext context) {
		final point = LatLng(incident.lat, incident.lng);

		return ClipRRect(
			borderRadius: BorderRadius.circular(16),
			child: SizedBox(
				height: 220,
				width: double.infinity,
				child: GoogleMap(
					initialCameraPosition: CameraPosition(target: point, zoom: 15),
					markers: {
						Marker(
							markerId: MarkerId(incident.id ?? 'incident-marker'),
							position: point,
							infoWindow: InfoWindow(title: incident.title),
						),
					},
					zoomControlsEnabled: false,
					myLocationButtonEnabled: false,
					mapToolbarEnabled: false,
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
			IncidentStatus.pending => ('Cho xu ly', Colors.orange),
			IncidentStatus.inProgress => ('Dang xu ly', Colors.blue),
			IncidentStatus.resolved => ('Da xu ly', Colors.green),
		};

		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				color: color.withValues(alpha: 0.14),
				borderRadius: BorderRadius.circular(999),
			),
			child: Text(
				label,
				style: Theme.of(context).textTheme.labelLarge?.copyWith(
					color: color,
					fontWeight: FontWeight.w700,
				),
			),
		);
	}
}
