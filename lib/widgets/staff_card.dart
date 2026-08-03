import 'package:flutter/material.dart';

class StaffCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final int serviceCount;
  final String? photoUrl;
  final ValueChanged<bool> onToggleActive;

  const StaffCard({
    Key? key,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.serviceCount,
    this.photoUrl,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null 
                  ? Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                      style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role,
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$serviceCount Services',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: onToggleActive,
              activeColor: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
