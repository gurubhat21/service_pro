import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/widgets/service_card.dart';
import 'package:service_pro/widgets/stats_card.dart';
import 'package:service_pro/widgets/empty_state.dart';
import 'package:service_pro/screens/staff/staff_service_list.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceRequestProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await serviceProvider.loadServices(authProvider.currentUser!.uid);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final staffName = authProvider.currentUser?.displayName ?? 'Staff';

    final tabs = [
      _buildDashboardView(staffName),
      const StaffServiceList(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(_currentIndex == 0 ? 'Dashboard' : 'My Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await authProvider.signOut();
              // Navigation to login should be handled by an AuthWrapper listening to AuthProvider
            },
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list),
            label: 'Services',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(String staffName) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF00BCD4),
      backgroundColor: const Color(0xFF1C2128),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $staffName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fade().slideY(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Here is your service overview today.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ).animate().fade(delay: 100.ms),
            const SizedBox(height: 24),
            Consumer<ServiceRequestProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
                }

                final assignedCount = provider.services.where((s) => s.status == ServiceStatus.pending).length;
                final inProgressCount = provider.services.where((s) => s.status == ServiceStatus.inProgress || s.status == ServiceStatus.clearRequested).length;
                final completedCount = provider.services.where((s) => s.status == ServiceStatus.completed).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Assigned',
                            count: assignedCount,
                            icon: Icons.assignment,
                            gradientColors: const [Color(0xFFF57F17), Color(0xFFFFB300)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'In Progress',
                            count: inProgressCount,
                            icon: Icons.build_circle,
                            gradientColors: const [Color(0xFF0277BD), Color(0xFF03A9F4)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Completed',
                            count: completedCount,
                            icon: Icons.check_circle,
                            gradientColors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Assignments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ).animate().fade(delay: 300.ms),
                    const SizedBox(height: 16),
                    _buildRecentServices(provider.services),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentServices(List<dynamic> allServices) {
    // Filter out completed ones for recent tasks, take top 5
    final recentServices = allServices.where((s) => s.status != ServiceStatus.completed).take(5).toList();

    if (recentServices.isEmpty) {
      return const EmptyState(
        icon: Icons.done_all,
        title: 'All caught up!',
        subtitle: 'You have no pending assignments right now.',
      ).animate().fade(delay: 400.ms);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentServices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = recentServices[index];
        return ServiceCard(
          service: service,
          onTap: () {
            Navigator.pushNamed(context, '/staff/service_detail', arguments: service);
          },
        ).animate().fade(delay: Duration(milliseconds: 400 + (100 * index))).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
