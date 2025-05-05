import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dashboard/views/admin_settings_view.dart';
import '../modules/dashboard/views/users_view.dart';
import '../modules/dashboard/views/loans_view.dart';
import '../modules/dashboard/views/pending_loans_view.dart';
import '../modules/dashboard/views/security_settings_view.dart';
import '../modules/dashboard/views/loan_settings_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const AdminSettingsView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.USERS,
      page: () => UsersView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.LOANS,
      page: () => LoansView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PENDING_LOANS,
      page: () => PendingLoansView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SECURITY_SETTINGS,
      page: () => const SecuritySettingsView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.LOAN_SETTINGS,
      page: () => const LoanSettingsView(),
      binding: DashboardBinding(),
    ),
  ];
} 