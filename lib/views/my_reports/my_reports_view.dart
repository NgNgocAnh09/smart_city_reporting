import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../models/incident_model.dart';
import './widgets/dismissible_item.dart';

class MyReportsView extends StatelessWidget {
  const MyReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy provider để biết ai đang đăng nhập
    final authProvider = context.read<AuthProvider>();
    
    // Sử dụng đúng biến 'user' từ AuthProvider của bạn
    final currentUid = authProvider.user?.uid ?? ""; 

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nhật ký của tôi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ xử lý'),
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Đã xong'),
            ],
          ),
        ),
        body: Consumer<IncidentProvider>(
          builder: (context, provider, child) {
            // Lọc ra các sự cố CỦA RIÊNG người dùng đang đăng nhập
            final myIncidents = provider.incidents
                .where((item) => item.uid == currentUid)
                .toList();

            return TabBarView(
              children: [
                _buildList(context, myIncidents, IncidentStatus.pending),
                _buildList(context, myIncidents, IncidentStatus.inProgress),
                _buildList(context, myIncidents, IncidentStatus.resolved),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Incident> allMyItems, IncidentStatus status) {
    // Lọc tiếp theo trạng thái cho từng Tab
    final filteredList = allMyItems.where((item) => item.status == status).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text("Không có báo cáo nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredList.length, 
      itemBuilder: (context, index) {
        final item = filteredList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DismissibleItem(
            incident: item,
            // SỬA LỖI ĐIỀU HƯỚNG: Phải truyền 'item' thay vì 'item.id'
            onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
            confirmDismiss: (direction) async => await _showDeleteDialog(context, item.id!),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String id) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              context.read<IncidentProvider>().deleteIncident(id);
              Navigator.pop(context, true);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}