import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/widgets/status_badge.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detailed view of a service request
class ServiceDetailScreen extends StatelessWidget {
  final ServiceRequestModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF1C2128),
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard().animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            // Customer info
            _buildInfoCard(
              title: 'Customer',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Name', service.customerName ?? 'N/A'),
                _buildInfoRow('Phone', service.customerPhone ?? 'N/A', isTappable: true, onTap: () => _callPhone(service.customerPhone)),
              ],
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 12),

            // Service details
            _buildInfoCard(
              title: 'Service Details',
              icon: Icons.handyman_outlined,
              children: [
                _buildInfoRow('Type', service.serviceType.label),
                _buildInfoRow('Title', service.title),
                if (service.description != null && service.description!.isNotEmpty)
                  _buildInfoRow('Description', service.description!),
                _buildInfoRow('Priority', service.priority.label),
                if (service.scheduledDate != null)
                  _buildInfoRow('Scheduled', DateFormat('EEE, MMM dd, yyyy – hh:mm a').format(service.scheduledDate!)),
                _buildInfoRow('Created', DateFormat('MMM dd, yyyy').format(service.createdAt)),
                if (service.completedDate != null)
                  _buildInfoRow('Completed', DateFormat('MMM dd, yyyy').format(service.completedDate!)),
              ],
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 12),

            // Staff info
            _buildInfoCard(
              title: 'Assigned Staff',
              icon: Icons.people_outline,
              children: [
                _buildInfoRow('Staff', service.assignedStaffName ?? 'Unassigned'),
              ],
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 12),

            // Location
            if (service.locationAddress != null || service.locationLat != null)
              _buildInfoCard(
                title: 'Location',
                icon: Icons.location_on_outlined,
                children: [
                  if (service.locationAddress != null)
                    _buildInfoRow('Address', service.locationAddress!),
                  if (service.locationLat != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openMaps(service.locationLat!, service.locationLng!),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Open in Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00BCD4),
                            side: const BorderSide(color: Color(0xFF00BCD4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                ],
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.05),

            const SizedBox(height: 32),

            // Status timeline
            _buildStatusTimeline().animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final typeIcon = _getTypeIconData(service.serviceType);
    final _ = _getStatusColor(service.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A237E).withOpacity(0.6), const Color(0xFF0D1117)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(typeIcon, color: const Color(0xFF00BCD4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(service.serviceType.label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatusBadge(status: service.status),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(service.priority).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(service.priority.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getPriorityColor(service.priority))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF00BCD4), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTappable = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
          ),
          Expanded(
            child: isTappable
                ? InkWell(
                    onTap: onTap,
                    child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF00BCD4), fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
                  )
                : Text(value, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final steps = [
      {'label': 'Pending', 'status': ServiceStatus.pending},
      {'label': 'In Progress', 'status': ServiceStatus.inProgress},
      {'label': 'Clear Requested', 'status': ServiceStatus.clearRequested},
      {'label': 'Completed', 'status': ServiceStatus.completed},
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == service.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isCompleted = i <= currentIndex;
            final isCurrent = i == currentIndex;
            final color = isCompleted ? const Color(0xFF00BCD4) : Colors.white.withOpacity(0.2);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? color.withOpacity(0.2) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: isCompleted ? const Icon(Icons.check, size: 14, color: Color(0xFF00BCD4)) : null,
                  ),
                  if (i < steps.length - 1)
                    Container(width: 2, height: 30, color: color),
                ]),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  IconData _getTypeIconData(ServiceType type) {
    switch (type) {
      case ServiceType.computer: return Icons.computer;
      case ServiceType.laptop: return Icons.laptop;
      case ServiceType.cctv: return Icons.videocam;
      case ServiceType.solar: return Icons.solar_power;
      case ServiceType.ups: return Icons.battery_charging_full;
    }
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending: return const Color(0xFFFFB300);
      case ServiceStatus.inProgress: return const Color(0xFF42A5F5);
      case ServiceStatus.clearRequested: return const Color(0xFFFF9800);
      case ServiceStatus.completed: return const Color(0xFF66BB6A);
      case ServiceStatus.cancelled: return const Color(0xFFEF5350);
    }
  }

  Color _getPriorityColor(ServicePriority p) {
    switch (p) {
      case ServicePriority.low: return const Color(0xFF66BB6A);
      case ServicePriority.medium: return const Color(0xFF42A5F5);
      case ServicePriority.high: return const Color(0xFFFFB300);
      case ServicePriority.urgent: return const Color(0xFFEF5350);
    }
  }

  void _callPhone(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  void _openMaps(double lat, double lng) {
    launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Service', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this service request?', style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
