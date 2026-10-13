import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNumber extends StatefulWidget {
  const VersionNumber({super.key});

  @override
  State<VersionNumber> createState() => _VersionNumberState();
}

class _VersionNumberState extends State<VersionNumber> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }
        final info = snapshot.data!;
        return Center(
          child: Text(
            'Version ${info.version} (${info.buildNumber})',
            style:
                context.textTheme.bodySmall?.copyWith(color: AppColors.fgMuted),
          ),
        );
      },
    );
  }
}
