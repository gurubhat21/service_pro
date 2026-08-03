import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/widgets/service_card.dart';
import 'package:service_pro/widgets/empty_state.dart';

class StaffServiceList extends StatefulWidget {
  const StaffServiceList({super.key});

  @override
  State<StaffServiceList> createState() => _StaffServiceListState();
}

class _StaffServiceListState extends State<StaffServiceList> {
  String _searchQuery = '';
  ServiceStatus? _selectedStatus; // null means 'All'

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
        }

        // Apply filters
        var filteredServices = provider.services.where((service) {
          final matchesStatus = _selectedStatus == null || service.status == _selectedStatus;
          final searchLower = _searchQuery.toLowerCase();
          final matchesSearch = service.title.toLowerCase().contains(searchLower) ||
              (service.customerName ?? '').toLowerCase().contains(searchLower) ||
              service.id.toLowerCase().contains(searchLower);
          return matchesStatus && matchesSearch;
        }).toList();

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1C2128),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ).animate().fade().slideY(begin: -0.2, end: 0),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  _buildFilterChip('Pending', ServiceStatus.pending),
                  _buildFilterChip('In Progress', ServiceStatus.inProgress),
                  _buildFilterChip('Clear Req', ServiceStatus.clearRequested),
                  _buildFilterChip('Completed', ServiceStatus.completed),
                ],
              ),
            ).animate().fade(delay: 100.ms),
            
            const SizedBox(height: 8),

            // List
            Expanded(
              child: filteredServices.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No Services Found',
                      subtitle: 'Try adjusting your search or filters.',
                    ).animate().fade(delay: 200.ms)
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Using auth provider to reload for current user could go here
                        // For now just notify listeners in provider
                        provider.searchServices('');
                      },
                      color: const Color(0xFF00BCD4),
                      backgroundColor: const Color(0xFF1C2128),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredServices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return ServiceCard(
                            service: service,
                            onTap: () {
                              Navigator.pushNamed(context, '/staff/service_detail', arguments: service);
                            },
                          ).animate().fade(delay: Duration(milliseconds: 200 + (50 * index)));
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, ServiceStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
        backgroundColor: const Color(0xFF161B22),
        selectedColor: const Color(0xFF00BCD4).withOpacity(0.3),
        checkmarkColor: const Color(0xFF00BCD4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.white12,
          ),
        ),
      ),
    );
  }
}
