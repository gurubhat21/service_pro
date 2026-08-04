import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/config/routes.dart';
import 'package:service_pro/models/customer_model.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/customer_provider.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/providers/staff_provider.dart';
import 'package:service_pro/widgets/service_type_selector.dart';

/// Create new service request form
class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  ServiceType _selectedType = ServiceType.computer;
  ServicePriority _selectedPriority = ServicePriority.medium;
  CustomerModel? _selectedCustomer;
  String? _selectedStaffId;
  DateTime? _scheduledDate;
  double? _locationLat;
  double? _locationLng;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Service Request')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Customer *'),
              const SizedBox(height: 8),
              _buildCustomerSelector(),
              const SizedBox(height: 24),
              _buildSectionLabel('Service Type'),
              const SizedBox(height: 10),
              ServiceTypeSelector(
                selectedType: _selectedType,
                onSelected: (type) => setState(() => _selectedType = type),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 24),
              _buildSectionLabel('Service Title *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: 'e.g., Laptop screen replacement',
                icon: Icons.title,
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(controller: _descriptionController, hint: 'Describe the issue...', icon: Icons.description_outlined, maxLines: 4),
              const SizedBox(height: 24),
              _buildSectionLabel('Priority'),
              const SizedBox(height: 10),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              _buildSectionLabel('Assign Staff'),
              const SizedBox(height: 8),
              _buildStaffSelector(),
              const SizedBox(height: 24),
              _buildSectionLabel('Schedule Date'),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildSectionLabel('Service Location'),
              const SizedBox(height: 8),
              _buildLocationSection(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitService,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4, shadowColor: const Color(0xFF00BCD4).withOpacity(0.3)),
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_circle_outline, size: 22), SizedBox(width: 10), Text('Create Service Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7)));

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, style: const TextStyle(color: Colors.white), validator: validator,
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.white.withOpacity(0.4), size: 20) : null, filled: true, fillColor: const Color(0xFF1C2128), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14)),
    );
  }

  Widget _buildCustomerSelector() {
    return Consumer<CustomerProvider>(builder: (context, provider, _) {
      final customers = provider.customers;
      return InkWell(
        onTap: () => _showCustomerPicker(customers), borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1C2128), borderRadius: BorderRadius.circular(14), border: Border.all(color: _selectedCustomer != null ? const Color(0xFF00BCD4).withOpacity(0.4) : Colors.white.withOpacity(0.06))),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: const Color(0xFF00BCD4).withOpacity(0.15), child: Icon(_selectedCustomer != null ? Icons.person : Icons.person_add, color: const Color(0xFF00BCD4), size: 20)),
            const SizedBox(width: 14),
            Expanded(child: _selectedCustomer != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_selectedCustomer!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)), const SizedBox(height: 2), Text(_selectedCustomer!.phone, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))]) : Text('Select a customer', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15))),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ]),
        ),
      );
    });
  }

  void _showCustomerPicker(List<CustomerModel> customers) {
    final searchCtrl = TextEditingController();
    List<CustomerModel> filtered = List.from(customers);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1C2128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setSheet) {
        return SizedBox(height: MediaQuery.of(ctx).size.height * 0.7, child: Column(children: [
          const SizedBox(height: 12), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(ctx); _showAddNewCustomerDialog(); }, icon: const Icon(Icons.person_add, size: 18), label: const Text('Add New'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00BCD4), side: const BorderSide(color: Color(0xFF00BCD4), width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(ctx); _importContactAsCustomer(); }, icon: const Icon(Icons.contacts, size: 18), label: const Text('Phone Book'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFFB300), side: const BorderSide(color: Color(0xFFFFB300), width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: TextField(controller: searchCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Search customers...', hintStyle: TextStyle(color: Colors.white.withAlpha(77)), prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(102)), filled: true, fillColor: const Color(0xFF0D1117), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), onChanged: (q) { setSheet(() { filtered = customers.where((c) => c.name.toLowerCase().contains(q.toLowerCase()) || c.phone.contains(q)).toList(); }); })),
          const SizedBox(height: 8),
          Expanded(child: filtered.isEmpty ? Center(child: Text('No customers found', style: TextStyle(color: Colors.white.withAlpha(102)))) : ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: filtered.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
            final c = filtered[i];
            return ListTile(onTap: () { setState(() { _selectedCustomer = c; _addressController.text = c.address ?? ''; _locationLat = c.latitude; _locationLng = c.longitude; }); Navigator.pop(ctx); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), tileColor: const Color(0xFF0D1117), leading: CircleAvatar(backgroundColor: const Color(0xFF00BCD4).withAlpha(38), child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w700))), title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), subtitle: Text(c.phone, style: TextStyle(color: Colors.white.withAlpha(128))), trailing: Icon(Icons.chevron_right, color: Colors.white.withAlpha(77)));
          })),
        ]));
      });
    });
  }

  void _showAddNewCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1C2128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) {
      return Padding(padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Text('Add New Customer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 24),
        _buildQuickField(nameCtrl, 'Name *', Icons.person_outline),
        const SizedBox(height: 14),
        _buildQuickField(phoneCtrl, 'Mobile Number *', Icons.phone_outlined, TextInputType.phone),
        const SizedBox(height: 14),
        _buildQuickField(emailCtrl, 'Email (optional)', Icons.email_outlined, TextInputType.emailAddress),
        const SizedBox(height: 14),
        _buildQuickField(addrCtrl, 'Address (optional)', Icons.location_on_outlined),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Name and phone are required'))); return; }
            final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
            context.read<CustomerProvider>().addCustomer(adminId: adminId, name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(), address: addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim());
            Navigator.pop(ctx);
            Future.delayed(const Duration(milliseconds: 500), () { if (mounted) { final custs = context.read<CustomerProvider>().customers; if (custs.isNotEmpty) setState(() { _selectedCustomer = custs.last; _addressController.text = _selectedCustomer?.address ?? ''; }); } });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nameCtrl.text.trim()} added & selected!'), backgroundColor: const Color(0xFF66BB6A)));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('Add & Select Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        )),
      ])));
    });
  }

  Widget _buildQuickField(TextEditingController controller, String hint, IconData icon, [TextInputType? keyboardType]) {
    return TextField(controller: controller, keyboardType: keyboardType, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withAlpha(77)), prefixIcon: Icon(icon, color: Colors.white.withAlpha(102), size: 20), filled: true, fillColor: const Color(0xFF0D1117), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
  }

  Future<void> _importContactAsCustomer() async {
    final permStatus = await FlutterContacts.permissions.request(PermissionType.read);
    if (permStatus != PermissionStatus.granted) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacts permission denied'), backgroundColor: Colors.red)); return; }
    final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone, ContactProperty.email, ContactProperty.address, ContactProperty.name});
    if (!mounted) return;
    final withPhone = contacts.where((c) => c.phones.isNotEmpty).toList();
    if (withPhone.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No contacts with phone numbers found'))); return; }
    if (!mounted) return;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1C2128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) {
      final sc = TextEditingController();
      List<Contact> flt = withPhone;
      return StatefulBuilder(builder: (ctx, ss) {
        return DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4, expand: false, builder: (ctx, scCtrl) {
          return Column(children: [
            Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(2)))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(children: [Icon(Icons.contacts, color: Color(0xFFFFB300), size: 24), SizedBox(width: 12), Text('Select Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))])),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: TextField(controller: sc, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Search contacts...', hintStyle: TextStyle(color: Colors.white.withAlpha(80)), prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(100)), filled: true, fillColor: const Color(0xFF0D1117), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12)), onChanged: (q) { ss(() { flt = withPhone.where((c) { final n = (c.displayName ?? '').toLowerCase(); return n.contains(q.toLowerCase()) || c.phones.first.number.contains(q); }).toList(); }); })),
            Expanded(child: ListView.builder(controller: scCtrl, itemCount: flt.length, padding: const EdgeInsets.symmetric(horizontal: 12), itemBuilder: (ctx, i) {
              final ct = flt[i]; final dn = ct.displayName ?? 'Unknown'; final ph = ct.phones.first.number;
              return ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFFFFB300).withAlpha(40), child: Text(dn.isNotEmpty ? dn[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold))),
                title: Text(dn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text(ph, style: TextStyle(color: Colors.white.withAlpha(120))),
                trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFFFB300)),
                onTap: () {
                  Navigator.pop(ctx);
                  final em = ct.emails.isNotEmpty ? ct.emails.first.address : '';
                  String addr = '';
                  if (ct.addresses.isNotEmpty) { final a = ct.addresses.first; addr = a.formatted ?? [a.street, a.city, a.state, a.postalCode, a.country].where((p) => p != null && p.isNotEmpty).join(', '); }
                  final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
                  context.read<CustomerProvider>().addCustomer(adminId: adminId, name: dn, phone: ph, email: em.isNotEmpty ? em : null, address: addr.isNotEmpty ? addr : null);
                  Future.delayed(const Duration(milliseconds: 500), () { if (mounted) { final custs = context.read<CustomerProvider>().customers; if (custs.isNotEmpty) setState(() { _selectedCustomer = custs.last; _addressController.text = _selectedCustomer?.address ?? ''; }); } });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$dn added & selected!'), backgroundColor: const Color(0xFF66BB6A)));
                },
              );
            })),
          ]);
        });
      });
    });
  }

  Widget _buildPrioritySelector() {
    return Row(children: ServicePriority.values.map((p) {
      final sel = _selectedPriority == p;
      final c = _getPriorityColor(p);
      return Expanded(child: Padding(padding: EdgeInsets.only(right: p != ServicePriority.urgent ? 8 : 0), child: InkWell(onTap: () => setState(() => _selectedPriority = p), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: sel ? c.withOpacity(0.2) : const Color(0xFF1C2128), borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? c : Colors.white.withOpacity(0.06), width: sel ? 1.5 : 1)), child: Column(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(height: 6), Text(p.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? c : Colors.white.withOpacity(0.5)))])))));
    }).toList());
  }

  Color _getPriorityColor(ServicePriority p) { switch (p) { case ServicePriority.low: return const Color(0xFF66BB6A); case ServicePriority.medium: return const Color(0xFF42A5F5); case ServicePriority.high: return const Color(0xFFFFB300); case ServicePriority.urgent: return const Color(0xFFEF5350); } }

  Widget _buildStaffSelector() {
    return Consumer<StaffProvider>(builder: (context, provider, _) {
      final staffList = provider.staffList.where((s) => s.isActive).toList();
      return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF1C2128), borderRadius: BorderRadius.circular(14)), child: DropdownButtonHideUnderline(child: DropdownButton<String?>(value: _selectedStaffId, isExpanded: true, hint: Text('Select staff (optional)', style: TextStyle(color: Colors.white.withOpacity(0.4))), dropdownColor: const Color(0xFF1C2128), style: const TextStyle(color: Colors.white), items: [const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')), ...staffList.map((s) => DropdownMenuItem<String?>(value: s.uid, child: Text('${s.name} (${s.role.label})')))], onChanged: (v) => setState(() => _selectedStaffId = v))));
    });
  }

  Widget _buildDatePicker() {
    return InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(14), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2128), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.4), size: 20), const SizedBox(width: 12), Text(_scheduledDate != null ? DateFormat('EEE, MMM dd, yyyy – hh:mm a').format(_scheduledDate!) : 'Pick a date (optional)', style: TextStyle(color: _scheduledDate != null ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 14)), const Spacer(), if (_scheduledDate != null) InkWell(onTap: () => setState(() => _scheduledDate = null), child: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 18))])));
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: _scheduledDate ?? DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), builder: (c, child) => Theme(data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4), surface: Color(0xFF1C2128))), child: child!));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (c, child) => Theme(data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4), surface: Color(0xFF1C2128))), child: child!));
    if (time == null || !mounted) return;
    setState(() { _scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute); });
  }

  Widget _buildLocationSection() {
    return Column(children: [
      if (_selectedCustomer?.latitude != null) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF66BB6A).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF66BB6A).withOpacity(0.3))), child: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 18), const SizedBox(width: 8), const Expanded(child: Text("Using customer's saved location", style: TextStyle(color: Color(0xFF66BB6A), fontSize: 13))), TextButton(onPressed: _pickNewLocation, child: const Text('Change', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 12)))])),
      InkWell(onTap: _pickNewLocation, borderRadius: BorderRadius.circular(14), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2128), borderRadius: BorderRadius.circular(14), border: Border.all(color: _locationLat != null ? const Color(0xFF00BCD4).withOpacity(0.3) : Colors.white.withOpacity(0.06))), child: Row(children: [Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.4), size: 22), const SizedBox(width: 12), Expanded(child: Text(_locationLat != null ? (_addressController.text.isNotEmpty ? _addressController.text : '${_locationLat!.toStringAsFixed(4)}, ${_locationLng!.toStringAsFixed(4)}') : 'Pick location on map (optional)', style: TextStyle(color: _locationLat != null ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 14))), Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))]))),
    ]);
  }

  Future<void> _pickNewLocation() async {
    final result = await Navigator.pushNamed(context, AppRoutes.locationPicker);
    if (result is Map<String, dynamic>) { setState(() { _locationLat = result['latitude'] as double?; _locationLng = result['longitude'] as double?; if (result['address'] != null) _addressController.text = result['address'] as String; }); }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer'))); return; }
    setState(() => _isSubmitting = true);
    try {
      final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
      final staffProvider = context.read<StaffProvider>();
      String? staffName;
      if (_selectedStaffId != null) { final staff = staffProvider.staffList.where((s) => s.uid == _selectedStaffId).firstOrNull; staffName = staff?.name; }
      await context.read<ServiceRequestProvider>().createService(adminId: adminId, customerId: _selectedCustomer!.id, customerName: _selectedCustomer!.name, customerPhone: _selectedCustomer!.phone, serviceType: _selectedType, title: _titleController.text.trim(), description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), priority: _selectedPriority, assignedStaffId: _selectedStaffId, assignedStaffName: staffName, scheduledDate: _scheduledDate, locationLat: _locationLat, locationLng: _locationLng, locationAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim());
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service request created!'), backgroundColor: Color(0xFF66BB6A))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } finally { if (mounted) setState(() => _isSubmitting = false); }
  }
}
