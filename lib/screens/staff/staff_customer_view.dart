import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:service_pro/models/customer_model.dart';
import 'package:service_pro/providers/customer_provider.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/widgets/service_card.dart';
import 'package:service_pro/widgets/empty_state.dart';

class StaffCustomerView extends StatefulWidget {
  final String customerId;

  const StaffCustomerView({super.key, required this.customerId});

  @override
  State<StaffCustomerView> createState() => _StaffCustomerViewState();
}

class _StaffCustomerViewState extends State<StaffCustomerView> {
  CustomerModel? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Attempt to find customer in provider or fetch directly
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    // In a full implementation, we'd have a method to fetch a single customer if not loaded
    try {
      final customer = customerProvider.customers.firstWhere((c) => c.uid == widget.customerId);
      setState(() {
        _customer = customer;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error or fetch from firestore directly
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback to browser maps
      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch maps')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4))),
      );
    }

    if (_customer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(backgroundColor: const Color(0xFF161B22)),
        body: const EmptyState(
          icon: Icons.person_off,
          title: 'Customer Not Found',
          message: 'Could not load customer details.',
        ),
      );
    }

    final cust = _customer!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Customer Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(cust).animate().fade().slideY(begin: 0.1),
            const SizedBox(height: 24),
            _buildActionButtons(cust).animate().fade(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            const Text(
              'Service History',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 12),
            _buildServiceHistory().animate().fade(delay: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(CustomerModel cust) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
            child: Text(
              cust.name.isNotEmpty ? cust.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cust.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(cust.phoneNumber, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                if (cust.address != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(cust.address!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CustomerModel cust) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C2128),
              foregroundColor: const Color(0xFF00BCD4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white12),
              ),
            ),
            icon: const Icon(Icons.call),
            label: const Text('Call'),
            onPressed: () => _makePhoneCall(cust.phoneNumber),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.directions),
            label: const Text('Navigate'),
            onPressed: () {
              if (cust.latitude != null && cust.longitude != null) {
                _openMaps(cust.latitude!, cust.longitude!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No location coordinates available for this customer.')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceHistory() {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, child) {
        final history = provider.services.where((s) => s.customerId == widget.customerId).toList();

        if (history.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'No History',
            message: 'This customer has no associated service requests.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final service = history[index];
            return ServiceCard(
              service: service,
              onTap: () {
                Navigator.pushNamed(context, '/staff/service_detail', arguments: service);
              },
            );
          },
        );
      },
    );
  }
}
