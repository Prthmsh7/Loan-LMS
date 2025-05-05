part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const LOGIN = _Paths.LOGIN;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const SETTINGS = _Paths.SETTINGS;
  static const USERS = _Paths.USERS;
  static const LOANS = _Paths.LOANS;
  static const PENDING_LOANS = _Paths.PENDING_LOANS;
  static const SECURITY_SETTINGS = _Paths.SECURITY_SETTINGS;
  static const LOAN_SETTINGS = _Paths.LOAN_SETTINGS;
}

abstract class _Paths {
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const SETTINGS = '/settings';
  static const USERS = '/users';
  static const LOANS = '/loans';
  static const PENDING_LOANS = '/pending-loans';
  static const SECURITY_SETTINGS = '/security-settings';
  static const LOAN_SETTINGS = '/loan-settings';
} 