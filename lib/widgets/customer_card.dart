import 'package:flutter/material.dart';

class CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final bool hasLocation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCall;

  const CustomerCard({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    this.hasLocation = false,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
  }) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      color: theme.colorScheme.secondary,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: theme.colorScheme.error,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onCall,
              child: Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasLocation ? Icons.location_on : Icons.location_on_outlined, 
                  size: 16, 
                  color: hasLocation ? theme.colorScheme.secondary : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
