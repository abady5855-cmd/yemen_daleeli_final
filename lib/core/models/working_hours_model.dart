import 'package:flutter/material.dart';

/// نموذج ساعات العمل لكل يوم من أيام الأسبوع
class WorkingHoursModel {
  final String dayName; // اسم اليوم (السبت، الأحد، إلخ)
  final int dayIndex; // رقم اليوم (0 = السبت، 6 = الجمعة)
  final TimeOfDay? openingTime; // وقت الفتح
  final TimeOfDay? closingTime; // وقت الإغلاق
  final bool isClosed; // هل المحل مغلق في هذا اليوم
  final bool isHoliday; // هل هذا اليوم عطلة رسمية

  WorkingHoursModel({
    required this.dayName,
    required this.dayIndex,
    this.openingTime,
    this.closingTime,
    this.isClosed = false,
    this.isHoliday = false,
  });

  /// التحقق من ما إذا كان المحل مفتوحاً الآن
  bool isOpenNow() {
    if (isClosed || isHoliday) return false;
    if (openingTime == null || closingTime == null) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final openingMinutes = openingTime!.hour * 60 + openingTime!.minute;
    final closingMinutes = closingTime!.hour * 60 + closingTime!.minute;

    return nowMinutes >= openingMinutes && nowMinutes < closingMinutes;
  }

  /// تحويل من JSON إلى WorkingHoursModel
  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      dayName: json['dayName'] as String,
      dayIndex: json['dayIndex'] as int,
      openingTime: json['openingTime'] != null 
          ? TimeOfDay(
              hour: int.parse(json['openingTime'].split(':')[0]),
              minute: int.parse(json['openingTime'].split(':')[1]),
            )
          : null,
      closingTime: json['closingTime'] != null 
          ? TimeOfDay(
              hour: int.parse(json['closingTime'].split(':')[0]),
              minute: int.parse(json['closingTime'].split(':')[1]),
            )
          : null,
      isClosed: json['isClosed'] as bool? ?? false,
      isHoliday: json['isHoliday'] as bool? ?? false,
    );
  }

  /// تحويل من WorkingHoursModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      'dayIndex': dayIndex,
      'openingTime': openingTime != null ? '${openingTime!.hour}:${openingTime!.minute}' : null,
      'closingTime': closingTime != null ? '${closingTime!.hour}:${closingTime!.minute}' : null,
      'isClosed': isClosed,
      'isHoliday': isHoliday,
    };
  }
}

/// فئة مساعدة لإدارة ساعات العمل الأسبوعية
class WeeklyWorkingHours {
  final List<WorkingHoursModel> days;

  WeeklyWorkingHours({required this.days}) : assert(days.length == 7);

  /// الحصول على ساعات اليوم الحالي
  WorkingHoursModel getTodayWorkingHours() {
    final today = DateTime.now().weekday;
    // تحويل weekday من Flutter (1=الاثنين، 7=الأحد) إلى نموذجنا (0=السبت، 6=الجمعة)
    // الاثنين=1 -> 2، الأحد=7 -> 1، السبت=6 -> 0
    int dayIndex;
    switch (today) {
      case DateTime.saturday: dayIndex = 0; break;
      case DateTime.sunday: dayIndex = 1; break;
      case DateTime.monday: dayIndex = 2; break;
      case DateTime.tuesday: dayIndex = 3; break;
      case DateTime.wednesday: dayIndex = 4; break;
      case DateTime.thursday: dayIndex = 5; break;
      case DateTime.friday: dayIndex = 6; break;
      default: dayIndex = 0;
    }
    return days[dayIndex];
  }

  /// التحقق من ما إذا كان المحل مفتوحاً الآن
  bool isOpenNow() {
    return getTodayWorkingHours().isOpenNow();
  }

  /// تحويل من JSON إلى WeeklyWorkingHours
  factory WeeklyWorkingHours.fromJson(Map<String, dynamic> json) {
    final List<dynamic> daysJson = json['days'] as List<dynamic>? ?? [];
    if (daysJson.isEmpty) return createDefault();
    
    return WeeklyWorkingHours(
      days: daysJson.map((e) => WorkingHoursModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// تحويل من WeeklyWorkingHours إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'days': days.map((e) => e.toJson()).toList(),
    };
  }

  /// إنشاء ساعات عمل افتراضية (مفتوح من 9 صباحاً إلى 10 مساءً)
  static WeeklyWorkingHours createDefault() {
    const openingTime = TimeOfDay(hour: 9, minute: 0);
    const closingTime = TimeOfDay(hour: 22, minute: 0);

    return WeeklyWorkingHours(
      days: [
        WorkingHoursModel(dayName: 'السبت', dayIndex: 0, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الأحد', dayIndex: 1, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الاثنين', dayIndex: 2, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الثلاثاء', dayIndex: 3, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الأربعاء', dayIndex: 4, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الخميس', dayIndex: 5, openingTime: openingTime, closingTime: closingTime),
        WorkingHoursModel(dayName: 'الجمعة', dayIndex: 6, isClosed: true),
      ],
    );
  }
}
