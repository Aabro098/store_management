import 'dart:async';

import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/work_provider.dart';
import 'package:finco_customer/screens/Work/work_documents.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsModel {
  StatsModel({required this.title, required this.value, required this.color});

  final String title;
  final int value;
  final Color color;
}

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<WorkProvider>().fetchDocumentStats());
    });
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    final documentStats = workProvider.documentStats;
    final stats = [
      StatsModel(
        title: 'Pending',
        value: documentStats?.pending ?? 0,
        color: AppColors.warning,
      ),
      StatsModel(
        title: 'Verified',
        value: documentStats?.verified ?? 0,
        color: AppColors.success,
      ),
      StatsModel(
        title: 'Rejected',
        value: documentStats?.rejected ?? 0,
        color: AppColors.error,
      ),
    ];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizes.md),
          Text(
            'Uploads grouped by day — add multiple files to any date.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
              fontSize: AppSizes.fontSm,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: stats.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == stats.length - 1 ? 0 : AppSizes.sm,
                  ),
                  child: _statCard(stat),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppSizes.md),
          const WorkDetailsDocuments(),
        ],
      ),
    );
  }

  Widget _statCard(StatsModel stat) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.smMd,
      ),
      decoration: BoxDecoration(
        boxShadow: AppShadows.elevation,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: stat.color.withAlpha(32),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              stat.title,
              style: context.textTheme.bodySmall?.copyWith(color: stat.color),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.smMd),
            child: Text(
              stat.value.toString(),
              style: context.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
