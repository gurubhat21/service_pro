import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/models/clear_request_model.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'package:service_pro/widgets/empty_state.dart';

/// Screen for admin to approve/reject clear requests from staff
class ClearRequestsScreen extends StatefulWidget {
  const ClearRequestsScreen({super.key});

  @override
  State<ClearRequestsScreen> createState() => _ClearRequestsScreenState();
}

class _ClearRequestsScreenState extends State<ClearRequestsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Clear Requests')),
      body: StreamBuilder<List<ClearRequestModel>>(
        stream: _firestoreService.getPendingClearRequests(adminId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'No pending requests',
              subtitle: 'All clear requests have been processed',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request, context)
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn()
                  .slideX(begin: 0.05);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(ClearRequestModel request, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.approval, color: Color(0xFFFF9800), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.serviceTitle ?? 'Service Request',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested by ${request.staffName}',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Staff note
          if (request.note != null && request.note!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Staff Note:', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(request.note!, style: const TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),

          // Timestamp
          Text(
            'Requested on ${DateFormat('MMM dd, yyyy – hh:mm a').format(request.createdAt)}',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3)),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleReject(context, request),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5350),
                    side: const BorderSide(color: Color(0xFFEF5350)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleApprove(context, request),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleApprove(BuildContext context, ClearRequestModel request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Approve Clear Request', style: TextStyle(color: Colors.white)),
        content: Text(
          'Approve this clear request? The service will be marked as completed.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestoreService.respondToClearRequest(request.id, request.serviceRequestId, true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clear request approved!'), backgroundColor: Color(0xFF66BB6A)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66BB6A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context, ClearRequestModel request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Clear Request', style: TextStyle(color: Colors.white)),
        content: Text(
          'Reject this clear request? The service will remain in progress.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestoreService.respondToClearRequest(request.id, request.serviceRequestId, false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clear request rejected'), backgroundColor: Color(0xFFEF5350)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
