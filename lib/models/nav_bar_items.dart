import 'package:finco_customer/screens/Home/home_screen.dart';
import 'package:finco_customer/screens/Meetings/meetings_screen.dart';
import 'package:finco_customer/screens/Profile/profile_screen.dart';
import 'package:finco_customer/screens/Work/work_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NavTabItem {
  const NavTabItem({
    required this.icon,
    required this.label,
    this.pageBuilder,
  });

  final IconData icon;
  final String label;
  final Widget Function()? pageBuilder;

  static Widget _homePage() => const HomeScreen();
  static Widget _workPage() => const WorkScreen();
  static Widget _meetingsPage() => const MeetingsScreen();
  static Widget _profilePage() => const ProfileScreen();

  static List<NavTabItem> pageList() {
    return const [
      NavTabItem(
        icon: Icons.dashboard_outlined,
        label: 'Home',
        pageBuilder: _homePage,
      ),
      NavTabItem(
        icon: Iconsax.briefcase,
        label: 'Work',
        pageBuilder: _workPage,
      ),
      NavTabItem(
        icon: Iconsax.calendar,
        label: 'Meetings',
        pageBuilder: _meetingsPage,
      ),
      NavTabItem(
        icon: Iconsax.profile_circle,
        label: 'Profile',
        pageBuilder: _profilePage,
      ),
    ];
  }
}
