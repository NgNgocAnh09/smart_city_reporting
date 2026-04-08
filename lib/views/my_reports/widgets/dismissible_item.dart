import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/incident_model.dart';
import '../../home/widgets/incident_card.dart';
import '../../../providers/incident_provider.dart';

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
      direction: DismissDirection.endToStart, 
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
      child: Row(
        children: [
          Expanded(
            child: IncidentCard(
              incident: incident,
              onTap: onTap,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = Provider.of<IncidentProvider>(context, listen: false);
              if (incident.id == null) return;
              if (value == 'edit') {
                await _showEditDialog(context, provider, incident);
              } else if (value == 'in_progress') {
                await provider.updateIncident(incident.id!, {'status': IncidentStatus.inProgress.name});
              } else if (value == 'resolved') {
                await provider.updateIncident(incident.id!, {'status': IncidentStatus.resolved.name});
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Sửa sự cố')),
              const PopupMenuItem(value: 'in_progress', child: Text('Đánh dấu Đang xử lý')),
              const PopupMenuItem(value: 'resolved', child: Text('Đánh dấu Đã xử lý')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, IncidentProvider provider, Incident incident) async {
    final titleCtrl = TextEditingController(text: incident.title);
    final descCtrl = TextEditingController(text: incident.description);
    final addrCtrl = TextEditingController(text: incident.address);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa báo cáo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), minLines: 2, maxLines: 4),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              if (incident.id == null) return;
              
              await provider.updateIncident(incident.id!, {
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
              });

              
              if (!dialogContext.mounted) return;
              
              Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}