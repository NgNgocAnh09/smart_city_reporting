import 'package:flutter/material.dart';
import '../../../models/incident_model.dart';
import '../../home/widgets/incident_card.dart';

class DismissibleItem extends StatelessWidget {
  final Incident incident;
  final Future<bool?> Function(DismissDirection) confirmDismiss;
  final VoidCallback onTap;

  const DismissibleItem({
    super.key,
    required this.incident,
    required this.confirmDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(incident.id ?? incident.createdAt.toString()),
      direction: DismissDirection.endToStart, // Vuốt từ phải sang trái để xóa
      confirmDismiss: confirmDismiss,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: IncidentCard(
        incident: incident,
        onTap: onTap,
      ),
    );
  }
}