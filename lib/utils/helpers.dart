import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/config/constants.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 8) {
      return formatDate(date);
    } else if ((diff.inDays / 7).floor() >= 1) {
      return 'Last week';
    } else if (diff.inDays >= 2) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays >= 1) {
      return 'Yesterday';
    } else if (diff.inHours >= 2) {
      return '${diff.inHours} hours ago';
    } else if (diff.inHours >= 1) {
      return 'An hour ago';
    } else if (diff.inMinutes >= 2) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inMinutes >= 1) {
      return 'A minute ago';
    } else {
      return 'Just now';
    }
  }

  static IconData getServiceTypeIcon(ServiceType type) {
    switch (type) {
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
      default:
        return Icons.build;
    }
  }

  static Color getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.in_progress:
        return Colors.blue;
      case ServiceStatus.clear_requested:
        return Colors.purple;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getPriorityColor(ServicePriority priority) {
    switch (priority) {
      case ServicePriority.low:
        return Colors.green;
      case ServicePriority.medium:
        return Colors.orange;
      case ServicePriority.high:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }
}
