import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:service_pro/config/routes.dart';
import 'package:service_pro/models/customer_model.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/customer_provider.dart';
import 'package:service_pro/widgets/customer_card.dart';
import 'package:service_pro/widgets/empty_state.dart';

/// Customer management screen — add, edit, search customers
class CustomerManagement extends StatefulWidget {
  const CustomerManagement({super.key});

  @override
  State<CustomerManagement> createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (adminId.isNotEmpty) {
      context.read<CustomerProvider>().loadCustomers(adminId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFF1C2128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                context.read<CustomerProvider>().searchCustomers(query);
              },
            ),
          ),

          // Customer list
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
                  );
                }

                final customers = provider.filteredCustomers;

                if (customers.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No customers found',
                    subtitle: 'Add your first customer to start creating service requests',
                    actionLabel: 'Add Customer',
                    onAction: () => _showAddCustomerDialog(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadCustomers(),
                  color: const Color(0xFF00BCD4),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return CustomerCard(
                        customer: customers[index],
                        onEdit: () => _showEditCustomerDialog(context, customers[index]),
                        onDelete: () => _confirmDelete(context, customers[index]),
                        onMapTap: customers[index].latitude != null
                            ? () => _openMap(customers[index])
                            : null,
                      ).animate(delay: Duration(milliseconds: 40 * index)).fadeIn().slideX(begin: 0.05);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: const Color(0xFF00BCD4),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, [CustomerModel? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    double? lat = existing?.latitude;
    double? lng = existing?.longitude;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24, 16, 24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      existing != null ? 'Edit Customer' : 'Add Customer',
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildField(nameController, 'Name *', Icons.person_outline),
                    const SizedBox(height: 14),
                    _buildField(phoneController, 'Mobile Number *', Icons.phone_outlined, TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildField(emailController, 'Email (optional)', Icons.email_outlined, TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildField(addressController, 'Address', Icons.location_on_outlined),
                    const SizedBox(height: 14),

                    // Location picker button
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.locationPicker,
                        );
                        if (result is Map<String, dynamic>) {
                          setSheetState(() {
                            lat = result['latitude'] as double?;
                            lng = result['longitude'] as double?;
                            if (result['address'] != null) {
                              addressController.text = result['address'] as String;
                            }
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: lat != null
                                ? const Color(0xFF66BB6A).withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              lat != null ? Icons.check_circle : Icons.map_outlined,
                              color: lat != null ? const Color(0xFF66BB6A) : Colors.white.withOpacity(0.4),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lat != null
                                    ? 'Location set (${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)})'
                                    : 'Pick location on Google Maps',
                                style: TextStyle(
                                  color: lat != null ? Colors.white : Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name and phone are required')),
                            );
                            return;
                          }
                          final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
                          final provider = context.read<CustomerProvider>();

                          if (existing != null) {
                            provider.updateCustomer(existing.id, {
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'email': emailController.text.trim(),
                              'address': addressController.text.trim(),
                              'latitude': lat,
                              'longitude': lng,
                            });
                          } else {
                            provider.addCustomer(
                              adminId: adminId,
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                              address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                              latitude: lat,
                              longitude: lng,
                            );
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          existing != null ? 'Update Customer' : 'Add Customer',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    _showAddCustomerDialog(context, customer);
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, [TextInputType? keyboardType]) {
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

  void _confirmDelete(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Customer', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomerProvider>().deleteCustomer(customer.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openMap(CustomerModel customer) {
    // Open Google Maps with customer location
    if (customer.latitude != null && customer.longitude != null) {
      // Will use location_service to open maps
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening maps for ${customer.name}...')),
      );
    }
  }
}
