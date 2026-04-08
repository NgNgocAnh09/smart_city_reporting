import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import 'widgets/incident_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  IncidentStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Incident> _filterIncidents(List<Incident> incidents) {
    if (_searchQuery.trim().isEmpty) {
      return _statusFilter == null
          ? incidents
          : incidents.where((i) => i.status == _statusFilter).toList();
    }

    final query = _searchQuery.toLowerCase().trim();
    final searched = incidents
        .where((incident) => incident.title.toLowerCase().contains(query))
        .toList();

    return _statusFilter == null
        ? searched
        : searched.where((i) => i.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.watch<AuthProvider>().user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 16,
        title: SearchBar(
          controller: _searchController,
          hintText: 'Tìm kiếm sự cố...',
          leading: const Icon(Icons.search),
          elevation: const WidgetStatePropertyAll<double>(0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/my_reports'),
              icon: const Icon(Icons.folder_open, color: Colors.blue),
              label: const Text('Nhật ký', style: TextStyle(color: Colors.blue)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
        ],
      ),
      body: Consumer<IncidentProvider>(
        builder: (context, incidentProvider, _) {
          final filteredIncidents = _filterIncidents(incidentProvider.incidents);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Chờ xử lý'),
                        selected: _statusFilter == IncidentStatus.pending,
                        onSelected: (_) => setState(() => _statusFilter = IncidentStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Đang xử lý'),
                        selected: _statusFilter == IncidentStatus.inProgress,
                        onSelected: (_) => setState(() => _statusFilter = IncidentStatus.inProgress),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Đã xử lý'),
                        selected: _statusFilter == IncidentStatus.resolved,
                        onSelected: (_) => setState(() => _statusFilter = IncidentStatus.resolved),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: filteredIncidents.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.trim().isEmpty
                              ? 'Chưa có sự cố nào để hiển thị.'
                              : 'Không tìm thấy sự cố phù hợp.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredIncidents.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final incident = filteredIncidents[index];
                          return IncidentCard(
                            incident: incident,
                            onTap: () {
                              Navigator.pushNamed(context, '/detail', arguments: incident);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
