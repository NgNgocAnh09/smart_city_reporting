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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Incident> _filterIncidents(List<Incident> incidents) {
    if (_searchQuery.trim().isEmpty) {
      return incidents;
    }

    final query = _searchQuery.toLowerCase().trim();
    return incidents
        .where((incident) => incident.title.toLowerCase().contains(query))
        .toList();
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
          final filteredIncidents = _filterIncidents(
            incidentProvider.incidents,
          );

          if (filteredIncidents.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.trim().isEmpty
                    ? 'Chưa có sự cố nào để hiển thị.'
                    : 'Không tìm thấy sự cố phù hợp.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredIncidents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final incident = filteredIncidents[index];

              return IncidentCard(incident: incident, onTap: () {});
            },
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
