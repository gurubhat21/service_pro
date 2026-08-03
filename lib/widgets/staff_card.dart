import 'package:flutter/material.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/models/staff_model.dart';

/// Card for displaying staff member info
class StaffCard extends StatelessWidget {
  final StaffModel staff;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback? onRemove;

  const StaffCard({
    super.key,
    required this.staff,
    this.onToggleActive,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: staff.photoUrl != null
                      ? NetworkImage(staff.photoUrl!)
                      : null,
                  backgroundColor: const Color(0xFF00BCD4).withAlpha(30),
                  child: staff.photoUrl == null
                      ? Text(
                          staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Color(0xFF00BCD4),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        staff.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    staff.role.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00BCD4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Active', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 8),
                    if (onToggleActive != null)
                      Switch(
                        value: staff.isActive,
                        onChanged: onToggleActive,
                        activeTrackColor: const Color(0xFF00BCD4),
                      ),
                  ],
                ),
                if (onRemove != null)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.person_remove, size: 16, color: Colors.red),
                    label: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
