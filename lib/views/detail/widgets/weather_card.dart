import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
	const WeatherCard({super.key, required this.weatherText});

	final String weatherText;

	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: 0,
			color: Theme.of(
				context,
			).colorScheme.primaryContainer.withValues(alpha: 0.5),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
				child: Row(
					children: [
						const Icon(Icons.wb_cloudy_outlined),
						const SizedBox(width: 10),
						Expanded(
							child: Text(
								weatherText.trim().isEmpty
										? 'Chua co thong tin thoi tiet'
										: weatherText,
								style: Theme.of(context).textTheme.bodyLarge,
							),
						),
					],
				),
			),
		);
	}
}
