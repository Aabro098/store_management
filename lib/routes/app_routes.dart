import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';

typedef RouteWidgetBuilder = Widget Function(RouteSettings settings);

final Map<String, RouteWidgetBuilder> appRoutes = {
  LoginScreen.routeName: (_) => const LoginScreen(),
  HomeScreen.routeName: (_) => const HomeScreen(),
};
