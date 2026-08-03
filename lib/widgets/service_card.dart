import 'package:flutter/material.dart';
import 'package:service_pro/widgets/status_badge.dart';
// import 'package:flutter_animate/flutter_animate.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String customerName;
  final String status;
  final String scheduledDate;
  final String assignedStaff;
  final String priority;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.customerName,
    required this.status,
    required this.scheduledDate,
    required this.assignedStaff,
    required this.priority,
    required this.onTap,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: _getPriorityColor(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customerName,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            scheduledDate,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Assigned: $assignedStaff',
                            style: theme.textTheme.bodyMedium,
                          ),
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
    );

    // If you have flutter_animate in pubspec.yaml:
    // return card.animate().fadeIn().slideY(begin: 0.2, end: 0);
    return card;
  }
}
