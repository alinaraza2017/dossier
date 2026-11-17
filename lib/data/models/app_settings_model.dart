class AppSettingsModel {
  final String themeMode; // 'light', 'dark', 'system'
  final String defaultReminderOffsets; // '7,2'
  final String defaultReminderTime; // '09:00'
  final bool remindersOn;
  final bool billingAlertsOn;
  final bool syncOn;
  final bool onboardingDone;
  final String? lastSyncAt;
  final String? lastServerTime;
  final String? homeTrialCardHiddenUntil;

  const AppSettingsModel({
    this.themeMode = 'system',
    this.defaultReminderOffsets = '7,2',
    this.defaultReminderTime = '09:00',
    this.remindersOn = true,
    this.billingAlertsOn = true,
    this.syncOn = false,
    this.onboardingDone = false,
    this.lastSyncAt,
    this.lastServerTime,
    this.homeTrialCardHiddenUntil,
  });

  List<int> get defaultOffsetsList {
    return defaultReminderOffsets
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  AppSettingsModel copyWith({
    String? themeMode,
    String? defaultReminderOffsets,
    String? defaultReminderTime,
    bool? remindersOn,
    bool? billingAlertsOn,
    bool? syncOn,
    bool? onboardingDone,
    String? lastSyncAt,
    String? lastServerTime,
    String? homeTrialCardHiddenUntil,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      defaultReminderOffsets: defaultReminderOffsets ?? this.defaultReminderOffsets,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      remindersOn: remindersOn ?? this.remindersOn,
      billingAlertsOn: billingAlertsOn ?? this.billingAlertsOn,
      syncOn: syncOn ?? this.syncOn,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastServerTime: lastServerTime ?? this.lastServerTime,
      homeTrialCardHiddenUntil: homeTrialCardHiddenUntil ?? this.homeTrialCardHiddenUntil,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'themeMode': themeMode,
      'defaultReminderOffsets': defaultReminderOffsets,
      'defaultReminderTime': defaultReminderTime,
      'remindersOn': remindersOn ? 1 : 0,
      'billingAlertsOn': billingAlertsOn ? 1 : 0,
      'syncOn': syncOn ? 1 : 0,
      'onboardingDone': onboardingDone ? 1 : 0,
      'lastSyncAt': lastSyncAt,
      'lastServerTime': lastServerTime,
      'homeTrialCardHiddenUntil': homeTrialCardHiddenUntil,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: map['themeMode'] as String? ?? 'system',
      defaultReminderOffsets: map['defaultReminderOffsets'] as String? ?? '7,2',
      defaultReminderTime: map['defaultReminderTime'] as String? ?? '09:00',
      remindersOn: (map['remindersOn'] as int? ?? 1) == 1,
      billingAlertsOn: (map['billingAlertsOn'] as int? ?? 1) == 1,
      syncOn: (map['syncOn'] as int? ?? 0) == 1,
      onboardingDone: (map['onboardingDone'] as int? ?? 0) == 1,
      lastSyncAt: map['lastSyncAt'] as String?,
      lastServerTime: map['lastServerTime'] as String?,
      homeTrialCardHiddenUntil: map['homeTrialCardHiddenUntil'] as String?,
    );
  }
}
