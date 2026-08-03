import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/staff_provider.dart';
import 'package:service_pro/widgets/staff_card.dart';
import 'package:service_pro/widgets/empty_state.dart';

/// Staff management screen — add, view, and manage staff members
class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  void _loadStaff() {
    final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (adminId.isNotEmpty) {
      context.read<StaffProvider>().loadStaff(adminId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
            );
          }

          if (provider.staffList.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No staff members',
              subtitle: 'Add your first staff member to start assigning services',
              actionLabel: 'Add Staff',
              onAction: () => _showAddStaffDialog(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.staffList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final staff = provider.staffList[index];
              return StaffCard(
                staff: staff,
                onToggleActive: (bool value) {
                  provider.toggleStaffActive(staff.uid, value);
                },
                onRemove: () => _confirmRemoveStaff(context, staff.uid, staff.name),
              ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().slideX(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        backgroundColor: const Color(0xFF00BCD4),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    StaffRole selectedRole = StaffRole.technician;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C2128),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Add Staff Member',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter the staff member\'s Gmail address. They\'ll be linked to your account when they sign in.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 20),
                    _buildDialogField(nameController, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 14),
                    _buildDialogField(emailController, 'Gmail Address', Icons.email_outlined, TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildDialogField(phoneController, 'Mobile Number', Icons.phone_outlined, TextInputType.phone),
                    const SizedBox(height: 14),
                    // Role selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<StaffRole>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1C2128),
                          style: const TextStyle(color: Colors.white),
                          items: StaffRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.label),
                            );
                          }).toList(),
                          onChanged: (role) {
                            if (role != null) {
                              setDialogState(() => selectedRole = role);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (emailController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name and email are required')),
                      );
                      return;
                    }
                    final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
                    context.read<StaffProvider>().inviteStaff(
                      adminId: adminId,
                      email: emailController.text.trim(),
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      role: selectedRole,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, IconData icon, [TextInputType? keyboardType]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
        filled: true,
        fillColor: const Color(0xFF0D1117),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _confirmRemoveStaff(BuildContext context, String staffId, String staffName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Staff', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove $staffName?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StaffProvider>().removeStaff(staffId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
