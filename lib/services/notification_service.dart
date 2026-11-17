import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/utils/date_utils.dart';
import '../data/models/scholarship.dart';

class NotificationService {
  static const String channelId = 'dossier_deadline_channel';
  static const String channelName = 'Scholarship Deadlines';
  static const String channelDescription =
      'Notifications for upcoming scholarship deadlines';

  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService._({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  void Function(String scholarshipId)? onNotificationTap;

  Future<void> initialize({void Function(String scholarshipId)? onSelect}) async {
    if (onSelect != null) {
      onNotificationTap = onSelect;
    }
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            final scholarshipId = data['scholarshipId']?.toString();
            if (scholarshipId != null && onNotificationTap != null) {
              onNotificationTap!(scholarshipId);
            }
          } catch (e) {
            debugPrint('Failed to parse notification payload: $e');
          }
        }
      },
    );
  }

  Future<bool> requestPermissions() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted =
          await android.requestNotificationsPermission() ?? false;
      return granted;
    }
    return true;
  }

  static int getNotificationId(String scholarshipId, int offsetDays) {
    return (scholarshipId.hashCode.abs() % 100000) * 10 + (offsetDays % 10);
  }

  Future<void> syncRemindersForScholarship(
    Scholarship scholarship, {
    DateTime? referenceDate,
  }) async {
    if (scholarship.id.isEmpty) return;
    final sId = scholarship.id;

    await cancelForScholarship(sId);

    if (!scholarship.remindersOn || scholarship.isSubmitted) {
      return;
    }

    final deadlineDate = scholarship.deadlineDateTime;
    final offsets = scholarship.effectiveOffsets;

    for (final offset in offsets) {
      final reminderTime = AppDateUtils.calculateReminderTime(
        deadline: deadlineDate,
        offsetDays: offset,
        referenceDate: referenceDate,
      );

      if (reminderTime != null) {
        final title = offset == 0
            ? 'Due Today: ${scholarship.name}'
            : offset <= 2
                ? 'Urgent: Scholarship Deadline in $offset Days'
                : 'Scholarship Deadline Approaching';

        final body = offset == 0
            ? 'Your ${scholarship.name} application is due today! Complete your final submission.'
            : 'Your ${scholarship.name} application is due in $offset days. Check your remaining requirements.';

        await _scheduleLocalNotification(
          id: getNotificationId(sId, offset),
          title: title,
          body: body,
          scheduledDate: reminderTime,
          scholarshipId: sId,
        );
      }
    }
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String scholarshipId,
  }) async {
    final payload = jsonEncode({'scholarshipId': scholarshipId});
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (inner) {
        debugPrint('Failed to schedule notification: $inner');
      }
    }
  }

  Future<void> cancelForScholarship(String scholarshipId) async {
    try {
      for (final offset in [30, 14, 7, 3, 2, 1, 0]) {
        await _notificationsPlugin.cancel(getNotificationId(scholarshipId, offset));
      }
    } catch (e) {
      debugPrint('Error canceling notification for $scholarshipId: $e');
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
