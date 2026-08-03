import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/widgets/status_badge.dart';

/// A beautiful card widget displaying a service request
class ServiceCard extends StatelessWidget {
  final ServiceRequestModel service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (service.priority) {
      case ServicePriority.low:
        return const Color(0xFF66BB6A);
      case ServicePriority.medium:
        return const Color(0xFF42A5F5);
      case ServicePriority.high:
        return const Color(0xFFFFB300);
      case ServicePriority.urgent:
        return const Color(0xFFEF5350);
    }
  }

  IconData _getTypeIcon() {
    switch (service.serviceType) {
      case ServiceType.computer:
        return Icons.computer;
      case ServiceType.laptop:
        return Icons.laptop;
      case ServiceType.cctv:
        return Icons.videocam;
      case ServiceType.solar:
        return Icons.solar_power;
      case ServiceType.ups:
        return Icons.battery_charging_full;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: _getPriorityColor()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4).withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getTypeIcon(), color: const Color(0xFF00BCD4), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              service.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: service.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 15, color: Colors.white.withAlpha(100)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              service.customerName ?? 'Unknown',
                              style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 15, color: Colors.white.withAlpha(100)),
                          const SizedBox(width: 6),
                          Text(
                            service.scheduledDate != null
                                ? DateFormat('MMM dd, yyyy').format(service.scheduledDate!)
                                : 'Not scheduled',
                            style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150)),
                          ),
                          const Spacer(),
                          if (service.assignedStaffName != null) ...[
                            Icon(Icons.badge_outlined, size: 15, color: Colors.white.withAlpha(100)),
                            const SizedBox(width: 4),
                            Text(
                              service.assignedStaffName!,
                              style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(130)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }
}
