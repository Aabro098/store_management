import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/calendar_provider.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  static const List<String> _dayLabels = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendar, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingHoriz,
            vertical: AppSizes.paddingVert,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: AppShadows.elevation,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: calendar.goToPreviousMonth,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.xs),
                      child: Icon(Icons.arrow_back_ios, size: AppSizes.iconSm),
                    ),
                  ),
                  Text(
                    calendar.monthLabel,
                    style: context.textTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: calendar.goToNextMonth,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.xs),
                      child:
                          Icon(Icons.arrow_forward_ios, size: AppSizes.iconSm),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.smMd),
              SizedBox(
                height: 92.h,
                child: _WeekPageView(
                  key: ValueKey(calendar.focusedMonth),
                  initialPage: calendar.todayWeekIndex,
                  itemCount: calendar.weeks.length,
                  itemBuilder: (context, index) => _buildWeekRow(
                    context,
                    calendar,
                    calendar.weeks[index],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    CalendarProvider calendar,
    List<DateTime?> week,
  ) {
    return Row(
      children: List.generate(7, (index) {
        final date = index < week.length ? week[index] : null;
        return Expanded(
          child: date == null
              ? const SizedBox.shrink()
              : _DayCell(
                  date: date,
                  dayLabel: _dayLabels[date.weekday - 1],
                  selected: calendar.isSelected(date),
                  isToday: calendar.isToday(date),
                  onTap: () => calendar.selectDate(date),
                ),
        );
      }),
    );
  }
}

class _WeekPageView extends StatefulWidget {
  const _WeekPageView({
    required this.initialPage,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final int initialPage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<_WeekPageView> createState() => _WeekPageViewState();
}

class _WeekPageViewState extends State<_WeekPageView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.dayLabel,
    required this.selected,
    required this.isToday,
    this.onTap,
  });

  final DateTime? date;
  final String dayLabel;
  final bool selected;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox.shrink();
    }

    final textColor = selected ? AppColors.white : AppColors.black;

    return SizedBox(
      height: 92.h,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel,
                style: context.textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontSize: AppSizes.fontXs,
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: isToday || selected
                    ? BoxDecoration(
                        color: AppColors.white.withAlpha(100),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  '${date!.day}',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: selected
                        ? AppColors.white
                        : isToday
                            ? AppColors.primary
                            : AppColors.fg,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
