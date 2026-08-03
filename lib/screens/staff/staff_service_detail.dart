import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/models/clear_request_model.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/widgets/status_badge.dart';
import 'package:service_pro/screens/staff/staff_customer_view.dart';

class StaffServiceDetail extends StatefulWidget {
  final ServiceRequestModel service;

  const StaffServiceDetail({super.key, required this.service});

  @override
  State<StaffServiceDetail> createState() => _StaffServiceDetailState();
}

class _StaffServiceDetailState extends State<StaffServiceDetail> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _updateStatus(ServiceStatus newStatus, {String? note}) async {
    setState(() => _isLoading = true);
    try {
      if (newStatus == ServiceStatus.clearRequested) {
        // Create Clear Request Model
        final clearRequest = ClearRequestModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          serviceRequestId: widget.service.id,
          staffId: widget.service.assignedStaffId ?? '',
          staffName: widget.service.assignedStaffName ?? '',
          adminId: widget.service.adminId,
          note: note,
          status: ClearRequestStatus.pending,
          serviceTitle: widget.service.title,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createClearRequest(clearRequest);
      }
      
      await Provider.of<ServiceRequestProvider>(context, listen: false)
          .updateServiceStatus(widget.service.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRequestClearDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C2128),
          title: const Text('Request Clear', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you have completed this service and want to request a clear from the Admin?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Optional Note',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BCD4))),
                ),
                maxLines: 3,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(ServiceStatus.clearRequested, note: noteController.text.trim());
              },
              child: const Text('Request Clear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // In a real app we might want to listen to changes on this specific service
    final srv = widget.service;
    final dateStr = srv.scheduledDate != null 
        ? DateFormat('MMM dd, yyyy - HH:mm').format(srv.scheduledDate!)
        : 'Not scheduled';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Service Details'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(srv).animate().fade().slideY(begin: 0.1),
                const SizedBox(height: 16),
                _buildCustomerCard(srv).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                _buildDetailsCard(srv, dateStr).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              ],
            ),
          ),
      bottomNavigationBar: _buildBottomActions(srv),
    );
  }

  Widget _buildHeaderCard(ServiceRequestModel srv) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: #${srv.id.substring(0, 6)}',
                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
              ),
              StatusBadge(status: srv.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            srv.title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_getServiceIcon(srv.serviceType), color: const Color(0xFF00BCD4), size: 18),
              const SizedBox(width: 8),
              Text(
                srv.serviceType.name.toUpperCase(),
                style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _buildPriorityBadge(srv.priority),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(ServiceRequestModel srv) {
    return GestureDetector(
      onTap: () {
        // Navigate to read-only customer view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffCustomerView(customerId: srv.customerId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF161B22),
                  child: Text(
                    (srv.customerName ?? '').isNotEmpty ? srv.customerName![0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(srv.customerName ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(srv.locationAddress ?? 'No address provided', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ServiceRequestModel srv, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Details',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Description', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(srv.description ?? 'No description', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Scheduled Date', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF00BCD4), size: 16),
              const SizedBox(width: 8),
              Text(dateStr, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActions(ServiceRequestModel srv) {
    if (srv.status == ServiceStatus.pending) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF161B22),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _updateStatus(ServiceStatus.inProgress),
          child: const Text('Start Working', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    } else if (srv.status == ServiceStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF161B22),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _showRequestClearDialog,
          child: const Text('Request Clear', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    } else if (srv.status == ServiceStatus.clearRequested) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF161B22),
        child: const Text(
          'Waiting for Admin Approval...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    } else if (srv.status == ServiceStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF161B22),
        child: const Text(
          'Service Completed',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }
    return null;
  }

  IconData _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.computer: return Icons.computer;
      case ServiceType.laptop: return Icons.laptop;
      case ServiceType.cctv: return Icons.videocam;
      case ServiceType.solar: return Icons.solar_power;
      case ServiceType.ups: return Icons.power;
    }
  }

  Widget _buildPriorityBadge(ServicePriority priority) {
    Color color;
    switch (priority) {
      case ServicePriority.low: color = Colors.green; break;
      case ServicePriority.medium: color = Colors.orange; break;
      case ServicePriority.high: color = Colors.red; break;
      case ServicePriority.urgent: color = Colors.deepOrange; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
