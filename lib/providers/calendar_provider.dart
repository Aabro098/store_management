import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;

  String get monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void goToPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  void reset() {
    final now = DateTime.now();
    _focusedMonth = now;
    _selectedDate = now;
    notifyListeners();
  }

  /// Returns the weeks of the focused month grouped into rows of 7 days,
  /// excluding any blank placeholders for days belonging to adjacent months.
  /// The first/last row may therefore contain fewer than 7 days.
  List<List<DateTime>> get weeks {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final lastDay = DateTime(year, month + 1, 0).day;

    final result = <List<DateTime>>[];
    final currentWeek = <DateTime>[];

    for (var day = 1; day <= lastDay; day++) {
      currentWeek.add(DateTime(year, month, day));
      if (currentWeek.length == 7) {
        result.add(currentWeek.toList());
        currentWeek.clear();
      }
    }

    if (currentWeek.isNotEmpty) {
      result.add(currentWeek.toList());
    }

    return result;
  }

  /// Index of the week row inside [weeks] containing [date], or 0 if the
  /// date is not part of the focused month.
  int indexOfWeek(DateTime date) {
    final weeks = this.weeks;
    for (var i = 0; i < weeks.length; i++) {
      for (final day in weeks[i]) {
        if (date.year == day.year &&
            date.month == day.month &&
            date.day == day.day) {
          return i;
        }
      }
    }
    return 0;
  }

  /// Week row index containing the current day (0 when today is not in the
  /// focused month).
  int get todayWeekIndex => indexOfWeek(DateTime.now());

  String get selectedDateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  bool isSelected(DateTime date) =>
      _selectedDate.year == date.year &&
      _selectedDate.month == date.month &&
      _selectedDate.day == date.day;

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
