import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/config/routes.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/providers/customer_provider.dart';
import 'package:service_pro/providers/staff_provider.dart';
import 'package:service_pro/widgets/stats_card.dart';
import 'package:service_pro/widgets/service_card.dart';
import 'package:service_pro/widgets/empty_state.dart';

/// Admin dashboard with overview stats and recent services
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUser?.uid ?? '';
    if (adminId.isEmpty) return;

    context.read<ServiceRequestProvider>().loadServices(adminId);
    context.read<CustomerProvider>().loadCustomers(adminId);
    context.read<StaffProvider>().loadStaff(adminId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildServicesTab(),
          _buildCustomersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex <= 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createService),
              backgroundColor: const Color(0xFF00BCD4),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Service',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 1)
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00BCD4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 28),

              // Stats row
              _buildStatsGrid(),
              const SizedBox(height: 28),

              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 28),

              // Recent services
              _buildRecentServices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.adminModel?.name ?? 'Admin';
        final photoUrl = auth.currentUser?.photoURL;

        return Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00BCD4),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.clearRequests),
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  Consumer<ServiceRequestProvider>(
                    builder: (context, provider, _) {
                      final clearCount = provider.services
                          .where((s) => s.status == ServiceStatus.clearRequested)
                          .length;
                      if (clearCount == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF5350),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$clearCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, _) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.6,
          children: [
            StatsCard(
              title: 'Total',
              count: provider.totalCount,
              icon: Icons.inventory_2_outlined,
              gradientColors: const [Color(0xFF1A237E), Color(0xFF3949AB)],
            ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),
            StatsCard(
              title: 'Pending',
              count: provider.pendingCount,
              icon: Icons.pending_outlined,
              gradientColors: const [Color(0xFFF57F17), Color(0xFFFFB300)],
            ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1),
            StatsCard(
              title: 'In Progress',
              count: provider.inProgressCount,
              icon: Icons.autorenew,
              gradientColors: const [Color(0xFF0277BD), Color(0xFF03A9F4)],
            ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),
            StatsCard(
              title: 'Completed',
              count: provider.completedCount,
              icon: Icons.check_circle_outline,
              gradientColors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.people_outline,
              label: 'Staff',
              color: const Color(0xFF42A5F5),
              onTap: () => Navigator.pushNamed(context, AppRoutes.staffManagement),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.person_add_outlined,
              label: 'Customers',
              color: const Color(0xFF66BB6A),
              onTap: () => Navigator.pushNamed(context, AppRoutes.customerManagement),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.approval_outlined,
              label: 'Clear Req.',
              color: const Color(0xFFFFB300),
              onTap: () => Navigator.pushNamed(context, AppRoutes.clearRequests),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.alarm,
              label: 'Reminders',
              color: const Color(0xFFAB47BC),
              onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
            ),
          ],
        ),
      ],
    ).animate(delay: 300.ms).fadeIn();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2128),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<ServiceRequestProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
                ),
              );
            }

            final recentServices = provider.services.take(5).toList();

            if (recentServices.isEmpty) {
              return const EmptyState(
                icon: Icons.handyman_outlined,
                title: 'No services yet',
                subtitle: 'Tap the + button to create your first service request',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return ServiceCard(
                  service: recentServices[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.serviceDetail,
                    arguments: recentServices[index],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 80), // FAB clearance
      ],
    ).animate(delay: 400.ms).fadeIn();
  }

  Widget _buildServicesTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFF1C2128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (query) {
                context.read<ServiceRequestProvider>().searchServices(query);
              },
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 40,
            child: Consumer<ServiceRequestProvider>(
              builder: (context, provider, _) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('All', null, provider),
                    const SizedBox(width: 8),
                    ...ServiceStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          status.label,
                          status,
                          provider,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Services list
          Expanded(
            child: Consumer<ServiceRequestProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
                  );
                }

                final services = provider.filteredServices;

                if (services.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No services found',
                    subtitle: 'Try adjusting your filters',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF00BCD4),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        service: services[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.serviceDetail,
                          arguments: services[index],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    ServiceStatus? status,
    ServiceRequestProvider provider,
  ) {
    final isSelected = provider.selectedStatus == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => provider.filterByStatus(status),
      backgroundColor: const Color(0xFF1C2128),
      selectedColor: const Color(0xFF00BCD4).withOpacity(0.3),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF00BCD4)
            : Colors.white.withOpacity(0.1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCustomersTab() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add, color: Color(0xFF00BCD4)),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.customerManagement),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search customers...',
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
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No customers yet',
                    subtitle: 'Add your first customer to get started',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2128),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF00BCD4).withOpacity(0.15),
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00BCD4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.phone,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (customer.latitude != null)
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF66BB6A).withOpacity(0.7),
                              size: 20,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Column(
              children: [
                const SizedBox(height: 20),
                // Profile card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
                        backgroundImage: auth.currentUser?.photoURL != null
                            ? NetworkImage(auth.currentUser!.photoURL!)
                            : null,
                        child: auth.currentUser?.photoURL == null
                            ? const Icon(Icons.person, size: 40, color: Color(0xFF00BCD4))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.adminModel?.name ?? 'Admin',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.currentUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      if (auth.adminModel?.businessName != null &&
                          auth.adminModel!.businessName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          auth.adminModel!.businessName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu items
                _buildMenuItem(
                  icon: Icons.people_outline,
                  title: 'Staff Management',
                  subtitle: 'Add and manage your staff',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.staffManagement),
                ),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Customer Management',
                  subtitle: 'Manage customer database',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.customerManagement),
                ),
                _buildMenuItem(
                  icon: Icons.approval_outlined,
                  title: 'Clear Requests',
                  subtitle: 'Review completion requests',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.clearRequests),
                ),
                _buildMenuItem(
                  icon: Icons.alarm,
                  title: 'Reminders',
                  subtitle: 'Manage service reminders',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
                ),
                const Divider(color: Color(0xFF1C2128), height: 32),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  isDestructive: true,
                  onTap: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: const Color(0xFF1C2128),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : const Color(0xFF00BCD4))
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF00BCD4),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.white.withOpacity(0.4),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman_outlined),
            activeIcon: Icon(Icons.handyman),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filter by Service Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeFilterChip('All', null),
                  ...ServiceType.values.map((type) {
                    return _buildTypeFilterChip(type.label, type);
                  }),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterChip(String label, ServiceType? type) {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedType == type;
        return FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          onSelected: (_) {
            provider.filterByType(type);
            Navigator.pop(context);
          },
          backgroundColor: const Color(0xFF0D1117),
          selectedColor: const Color(0xFF00BCD4).withOpacity(0.3),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF00BCD4)
                : Colors.white.withOpacity(0.1),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      },
    );
  }
}
