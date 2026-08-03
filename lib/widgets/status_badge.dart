import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.amber;
        icon = Icons.access_time;
        break;
      case 'in progress':
      case 'inprogress':
        backgroundColor = Colors.blue;
        icon = Icons.autorenew;
        break;
      case 'clear requested':
      case 'clearrequested':
        backgroundColor = Colors.orange;
        icon = Icons.assignment_turned_in_outlined;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        border: Border.all(color: backgroundColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: backgroundColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: backgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
