import 'package:flutter/material.dart';
import 'package:service_pro/config/constants.dart';

/// A chip/badge widget that shows service status with color coding
class StatusBadge extends StatelessWidget {
  final ServiceStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ServiceStatus.pending:
        return const Color(0xFFFFB300);
      case ServiceStatus.inProgress:
        return const Color(0xFF42A5F5);
      case ServiceStatus.clearRequested:
        return const Color(0xFFFF9800);
      case ServiceStatus.completed:
        return const Color(0xFF66BB6A);
      case ServiceStatus.cancelled:
        return const Color(0xFFEF5350);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ServiceStatus.pending:
        return Icons.schedule;
      case ServiceStatus.inProgress:
        return Icons.autorenew;
      case ServiceStatus.clearRequested:
        return Icons.approval;
      case ServiceStatus.completed:
        return Icons.check_circle;
      case ServiceStatus.cancelled:
        return Icons.cancel;
    }
  }
}
