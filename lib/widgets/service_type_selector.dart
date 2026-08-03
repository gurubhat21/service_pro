import 'package:flutter/material.dart';
import 'package:service_pro/config/constants.dart';

/// Horizontal selector for service types (Computer, Laptop, CCTV, Solar, UPS)
class ServiceTypeSelector extends StatelessWidget {
  final ServiceType selectedType;
  final ValueChanged<ServiceType> onSelected;

  const ServiceTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ServiceType.values.map((type) {
          final isSelected = selectedType == type;
          final icon = _getTypeIcon(type);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(type.label),
              avatar: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF00BCD4),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(type);
              },
              backgroundColor: const Color(0xFF1C2128),
              selectedColor: const Color(0xFF00BCD4),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF00BCD4)
                    : Colors.white.withAlpha(25),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTypeIcon(ServiceType type) {
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
    }
  }
}
