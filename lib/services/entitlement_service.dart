import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum EntitlementStatus {
  free,
  trial,
  proActive,
  proCancelled,
  gracePeriod,
  accountHold,
  paused,
  expired,
  revoked,
}

class EntitlementState {
  final EntitlementStatus status;
  final String? plan; // 'monthly', 'yearly', 'trial'
  final DateTime? expiresAt;
  final DateTime? trialEndsAt;
  final bool autoRenewing;
  final DateTime lastVerifiedAt;

  const EntitlementState({
    required this.status,
    this.plan,
    this.expiresAt,
    this.trialEndsAt,
    this.autoRenewing = false,
    required this.lastVerifiedAt,
  });

  bool get isPro {
    return status == EntitlementStatus.trial ||
        status == EntitlementStatus.proActive ||
        status == EntitlementStatus.proCancelled ||
        status == EntitlementStatus.gracePeriod;
  }

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'plan': plan,
        'expiresAt': expiresAt?.toIso8601String(),
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'autoRenewing': autoRenewing,
        'lastVerifiedAt': lastVerifiedAt.toIso8601String(),
      };

  factory EntitlementState.fromMap(Map<String, dynamic> map) {
    return EntitlementState(
      status: EntitlementStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EntitlementStatus.free,
      ),
      plan: map['plan'] as String?,
      expiresAt: map['expiresAt'] != null ? DateTime.tryParse(map['expiresAt'] as String) : null,
      trialEndsAt: map['trialEndsAt'] != null ? DateTime.tryParse(map['trialEndsAt'] as String) : null,
      autoRenewing: map['autoRenewing'] as bool? ?? false,
      lastVerifiedAt: DateTime.tryParse(map['lastVerifiedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class EntitlementService {
  static const _storage = FlutterSecureStorage();
  static const _cacheKey = 'dossier_entitlement_state';
  static const _lastServerTimeKey = 'dossier_last_server_time';

  static EntitlementState _currentState = EntitlementState(
    status: EntitlementStatus.free,
    lastVerifiedAt: DateTime.now(),
  );

  static EntitlementState get current => _currentState;

  static Future<void> init() async {
    final cached = await _storage.read(key: _cacheKey);
    if (cached != null) {
      try {
        _currentState = EntitlementState.fromMap(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  static Future<void> updateEntitlement(EntitlementState state, {DateTime? serverTime}) async {
    _currentState = state;
    await _storage.write(key: _cacheKey, value: jsonEncode(state.toMap()));
    if (serverTime != null) {
      await _storage.write(key: _lastServerTimeKey, value: serverTime.toIso8601String());
    }
  }

  /// Validates device clock against rollback protection (§16.8)
  static Future<bool> isDeviceClockManipulated() async {
    final lastServerTimeStr = await _storage.read(key: _lastServerTimeKey);
    if (lastServerTimeStr != null) {
      final lastServer = DateTime.tryParse(lastServerTimeStr);
      if (lastServer != null && DateTime.now().isBefore(lastServer)) {
        return true; // Clock was wound back
      }
    }
    return false;
  }
}
