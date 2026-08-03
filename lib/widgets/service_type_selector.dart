import 'package:flutter/material.dart';

class ServiceTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelected;

  const ServiceTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> _serviceTypes = const [
    {'label': 'Computer', 'icon': Icons.computer},
    {'label': 'Laptop', 'icon': Icons.laptop},
    {'label': 'CCTV', 'icon': Icons.videocam},
    {'label': 'Solar', 'icon': Icons.solar_power},
    {'label': 'UPS', 'icon': Icons.power},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _serviceTypes.map((type) {
          final isSelected = selectedType == type['label'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(type['label'] as String),
              avatar: Icon(
                type['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.secondary,
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelected(type['label'] as String);
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
