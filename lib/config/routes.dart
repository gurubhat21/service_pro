import 'package:flutter/material.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/screens/splash_screen.dart';
import 'package:service_pro/screens/auth/login_screen.dart';
import 'package:service_pro/screens/auth/register_screen.dart';
import 'package:service_pro/screens/admin/admin_dashboard.dart';
import 'package:service_pro/screens/admin/staff_management.dart';
import 'package:service_pro/screens/admin/customer_management.dart';
import 'package:service_pro/screens/admin/create_service_screen.dart';
import 'package:service_pro/screens/admin/service_detail_screen.dart';
import 'package:service_pro/screens/admin/clear_requests_screen.dart';
import 'package:service_pro/screens/admin/reminders_screen.dart';
import 'package:service_pro/screens/staff/staff_dashboard.dart';
import 'package:service_pro/screens/staff/staff_service_list.dart';
import 'package:service_pro/screens/staff/staff_service_detail.dart';
import 'package:service_pro/widgets/location_picker.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String staffManagement = '/admin/staff';
  static const String customerManagement = '/admin/customers';
  static const String createService = '/admin/service/create';
  static const String serviceList = '/admin/services';
  static const String serviceDetail = '/service/detail';
  static const String clearRequests = '/admin/clear-requests';
  static const String reminders = '/admin/reminders';
  static const String staffDashboard = '/staff/dashboard';
  static const String staffServiceList = '/staff/services';
  static const String staffServiceDetail = '/staff/service/detail';
  static const String locationPicker = '/location-picker';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case staffManagement:
        return MaterialPageRoute(builder: (_) => const StaffManagement());
      case customerManagement:
        return MaterialPageRoute(builder: (_) => const CustomerManagement());
      case createService:
        return MaterialPageRoute(builder: (_) => const CreateServiceScreen());
      case serviceList:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case serviceDetail:
        final service = settings.arguments as ServiceRequestModel;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: service),
        );
      case clearRequests:
        return MaterialPageRoute(builder: (_) => const ClearRequestsScreen());
      case reminders:
        return MaterialPageRoute(builder: (_) => const RemindersScreen());
      case staffDashboard:
        return MaterialPageRoute(builder: (_) => const StaffDashboard());
      case staffServiceList:
        return MaterialPageRoute(builder: (_) => const StaffServiceList());
      case staffServiceDetail:
        final service = settings.arguments as ServiceRequestModel;
        return MaterialPageRoute(
          builder: (_) => StaffServiceDetail(service: service),
        );
      case locationPicker:
        return MaterialPageRoute(builder: (_) => const LocationPickerScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
