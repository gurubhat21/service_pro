/// Service type enumeration for different service categories
enum ServiceType {
  computer,
  laptop,
  cctv,
  solar,
  ups,
}

/// Extension to add display properties to ServiceType
extension ServiceTypeExtension on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.computer:
        return 'Computer';
      case ServiceType.laptop:
        return 'Laptop';
      case ServiceType.cctv:
        return 'CCTV';
      case ServiceType.solar:
        return 'Solar';
      case ServiceType.ups:
        return 'UPS';
    }
  }

  String get icon {
    switch (this) {
      case ServiceType.computer:
        return '💻';
      case ServiceType.laptop:
        return '💻';
      case ServiceType.cctv:
        return '📹';
      case ServiceType.solar:
        return '☀️';
      case ServiceType.ups:
        return '🔋';
    }
  }

  int get iconCodePoint {
    switch (this) {
      case ServiceType.computer:
        return 0xe30a; // Icons.computer
      case ServiceType.laptop:
        return 0xe31e; // Icons.laptop
      case ServiceType.cctv:
        return 0xf06bb; // Icons.videocam
      case ServiceType.solar:
        return 0xf0635; // Icons.solar_power
      case ServiceType.ups:
        return 0xe1a4; // Icons.battery_charging_full
    }
  }
}

/// Service request status
enum ServiceStatus {
  pending,
  inProgress,
  clearRequested,
  completed,
  cancelled,
}

/// Extension to add display properties to ServiceStatus
extension ServiceStatusExtension on ServiceStatus {
  String get label {
    switch (this) {
      case ServiceStatus.pending:
        return 'Pending';
      case ServiceStatus.inProgress:
        return 'In Progress';
      case ServiceStatus.clearRequested:
        return 'Clear Requested';
      case ServiceStatus.completed:
        return 'Completed';
      case ServiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get firestoreValue {
    switch (this) {
      case ServiceStatus.pending:
        return 'pending';
      case ServiceStatus.inProgress:
        return 'in_progress';
      case ServiceStatus.clearRequested:
        return 'clear_requested';
      case ServiceStatus.completed:
        return 'completed';
      case ServiceStatus.cancelled:
        return 'cancelled';
    }
  }

  static ServiceStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ServiceStatus.pending;
      case 'in_progress':
        return ServiceStatus.inProgress;
      case 'clear_requested':
        return ServiceStatus.clearRequested;
      case 'completed':
        return ServiceStatus.completed;
      case 'cancelled':
        return ServiceStatus.cancelled;
      default:
        return ServiceStatus.pending;
    }
  }
}

/// Clear request status
enum ClearRequestStatus {
  pending,
  approved,
  rejected,
}

extension ClearRequestStatusExtension on ClearRequestStatus {
  String get label {
    switch (this) {
      case ClearRequestStatus.pending:
        return 'Pending';
      case ClearRequestStatus.approved:
        return 'Approved';
      case ClearRequestStatus.rejected:
        return 'Rejected';
    }
  }

  String get firestoreValue {
    switch (this) {
      case ClearRequestStatus.pending:
        return 'pending';
      case ClearRequestStatus.approved:
        return 'approved';
      case ClearRequestStatus.rejected:
        return 'rejected';
    }
  }

  static ClearRequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ClearRequestStatus.pending;
      case 'approved':
        return ClearRequestStatus.approved;
      case 'rejected':
        return ClearRequestStatus.rejected;
      default:
        return ClearRequestStatus.pending;
    }
  }
}

/// Priority levels for service requests
enum ServicePriority {
  low,
  medium,
  high,
  urgent,
}

extension ServicePriorityExtension on ServicePriority {
  String get label {
    switch (this) {
      case ServicePriority.low:
        return 'Low';
      case ServicePriority.medium:
        return 'Medium';
      case ServicePriority.high:
        return 'High';
      case ServicePriority.urgent:
        return 'Urgent';
    }
  }

  String get firestoreValue {
    switch (this) {
      case ServicePriority.low:
        return 'low';
      case ServicePriority.medium:
        return 'medium';
      case ServicePriority.high:
        return 'high';
      case ServicePriority.urgent:
        return 'urgent';
    }
  }

  static ServicePriority fromString(String value) {
    switch (value) {
      case 'low':
        return ServicePriority.low;
      case 'medium':
        return ServicePriority.medium;
      case 'high':
        return ServicePriority.high;
      case 'urgent':
        return ServicePriority.urgent;
      default:
        return ServicePriority.medium;
    }
  }
}

/// User role in the app
enum UserRole {
  admin,
  staff,
}

/// Staff role types
enum StaffRole {
  technician,
  manager,
}

extension StaffRoleExtension on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.technician:
        return 'Technician';
      case StaffRole.manager:
        return 'Manager';
    }
  }

  String get firestoreValue {
    switch (this) {
      case StaffRole.technician:
        return 'technician';
      case StaffRole.manager:
        return 'manager';
    }
  }

  static StaffRole fromString(String value) {
    switch (value) {
      case 'technician':
        return StaffRole.technician;
      case 'manager':
        return StaffRole.manager;
      default:
        return StaffRole.technician;
    }
  }
}
