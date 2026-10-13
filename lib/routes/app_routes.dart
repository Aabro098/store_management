import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/screens/NavScreen/nav_screen.dart';
import 'package:finco_customer/screens/Notifications/notification_screen.dart';
import 'package:finco_customer/screens/Profile/change_password.dart';
import 'package:flutter/material.dart';

typedef RouteWidgetBuilder = Widget Function(RouteSettings settings);

final Map<String, RouteWidgetBuilder> appRoutes = {
  LoginScreen.routeName: (_) => const LoginScreen(),
  NavScreen.routeName: (_) => const NavScreen(),
  ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
  NotificationScreen.routeName: (_) => const NotificationScreen(),
};
