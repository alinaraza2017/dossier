import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_settings_service.dart';

class AiPriorityItem {
  final int rank;
  final String scholarshipName;
  final String reason;
  final int daysRemaining;
  final int progressPercent;
  final int? scholarshipId;

  const AiPriorityItem({
    required this.rank,
    required this.scholarshipName,
    required this.reason,
    required this.daysRemaining,
    required this.progressPercent,
    this.scholarshipId,
  });
}

class AiService {
  final http.Client _client;
  final LocalSettingsService _settings;

  AiService({http.Client? client, LocalSettingsService? settings})
    : _client = client ?? http.Client(),
      _settings = settings ?? LocalSettingsService.instance;

  String? getApiKey() {
    // 1. In-app saved key (LocalSettingsService)
    final savedKey = _settings.getAiApiKey();
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      return savedKey.trim();
    }
    // 2. Compile-time environment variable (e.g. --dart-define=GEMINI_API_KEY=xxx)
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return null;
  }

  bool get isConfigured => getApiKey() != null;

  // ==========================================
  // FEATURE 1: Checklist Generator
  // ==========================================
  Future<List<String>> generateChecklist(String requirementText) async {
    final trimmedText = requirementText.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError(
        'Please provide requirement text to generate a checklist.',
      );
    }

    final apiKey = getApiKey();
    if (apiKey == null) {
      // Return rule-based fallback extraction if no API key is configured
      return _fallbackExtractChecklist(trimmedText);
    }

    try {
      final prompt =
          '''
Extract the list of required documents and tasks from the text below. 
Return ONLY a valid JSON array of short, clean item names (strings). 
If a quantity is stated (such as "two recommendation letters" or "3 references"), create separate numbered items such as "Recommendation Letter 1" and "Recommendation Letter 2".
Do not include markdown formatting or explanations outside the JSON array.

Text:
$trimmedText
''';

      final responseText = await _callGeminiApi(prompt, apiKey);
      final parsedList = _parseJsonArray(responseText);

      if (parsedList.isNotEmpty) {
        return parsedList;
      } else {
        return _fallbackExtractChecklist(trimmedText);
      }
    } catch (e) {
      debugPrint(
        'AI Checklist Generation failed, using rule-based fallback: $e',
      );
      return _fallbackExtractChecklist(trimmedText);
    }
  }

  // ==========================================
  // FEATURE 2: Priority Recommendations
  // ==========================================
  Future<List<AiPriorityItem>> generatePriority({
    required List<Map<String, dynamic>> activeApplications,
  }) async {
    if (activeApplications.isEmpty) {
      return [];
    }

    final apiKey = getApiKey();
    if (apiKey == null) {
      return _fallbackPriority(activeApplications);
    }

    try {
      final sanitizedData = activeApplications.map((app) {
        return {
          'id': app['id'],
          'name': app['name'],
          'daysRemaining': app['daysRemaining'],
          'progressPercent': app['progressPercent'],
          'remainingRequirements': app['remainingRequirements'],
        };
      }).toList();

      final prompt =
          '''
You are an academic advisor. Analyze the active scholarship applications below and recommend the priority order to work on them.
Prioritize nearest deadlines first, especially those with lower progress or more remaining requirements.
Return ONLY a valid JSON array of objects with the exact keys:
[
  {
    "id": 1,
    "name": "Scholarship Name",
    "rank": 1,
    "reason": "1-2 sentence concise explanation why this should be prioritized"
  }
]

Applications:
${jsonEncode(sanitizedData)}
''';

      final responseText = await _callGeminiApi(prompt, apiKey);
      final jsonList = _parseJsonObjectList(responseText);

      final List<AiPriorityItem> results = [];
      for (final item in jsonList) {
        final id = item['id'] as int?;
        final name = item['name'] as String? ?? 'Scholarship';
        final rank = item['rank'] as int? ?? (results.length + 1);
        final reason =
            item['reason'] as String? ??
            'Recommended based on deadline proximity and progress.';

        // Match with local data
        final localMatch = activeApplications.firstWhere(
          (a) => (id != null && a['id'] == id) || (a['name'] == name),
          orElse: () => {'daysRemaining': 0, 'progressPercent': 0, 'id': id},
        );

        results.add(
          AiPriorityItem(
            rank: rank,
            scholarshipName: localMatch['name'] as String? ?? name,
            reason: reason,
            daysRemaining: localMatch['daysRemaining'] as int? ?? 0,
            progressPercent: localMatch['progressPercent'] as int? ?? 0,
            scholarshipId: localMatch['id'] as int?,
          ),
        );
      }

      if (results.isNotEmpty) {
        results.sort((a, b) => a.rank.compareTo(b.rank));
        return results;
      }
      return _fallbackPriority(activeApplications);
    } catch (e) {
      debugPrint('AI Priority failed, using fallback: $e');
      return _fallbackPriority(activeApplications);
    }
  }

  // ==========================================
  // FEATURE 3: Progress Summary
  // ==========================================
  Future<String> generateProgressSummary({
    required List<Map<String, dynamic>> activeApplications,
  }) async {
    if (activeApplications.isEmpty) {
      return 'You currently have no active applications. Add a scholarship to begin planning!';
    }

    final apiKey = getApiKey();
    if (apiKey == null) {
      return _fallbackSummary(activeApplications);
    }

    try {
      final sanitizedData = activeApplications.map((app) {
        return {
          'name': app['name'],
          'daysRemaining': app['daysRemaining'],
          'progressPercent': app['progressPercent'],
          'remainingRequirements': app['remainingRequirements'],
        };
      }).toList();

      final prompt =
          '''
Generate a short 2 to 3 sentence progress summary for a student managing the following scholarship applications.
Mention the total number of active applications, the most urgent scholarship, remaining requirements, and a clear next action.
Do not use bullet points or markdown headings. Keep it calm, encouraging, and concise.

Applications:
${jsonEncode(sanitizedData)}
''';

      final responseText = await _callGeminiApi(prompt, apiKey);
      final cleanText = responseText.trim().replaceAll('```', '');
      if (cleanText.isNotEmpty) {
        return cleanText;
      }
      return _fallbackSummary(activeApplications);
    } catch (e) {
      debugPrint('AI Summary failed, using fallback: $e');
      return _fallbackSummary(activeApplications);
    }
  }

  // ==========================================
  // Core API Request Helper (Google Gemini 1.5 Flash default)
  // ==========================================
  Future<String> _callGeminiApi(String prompt, String apiKey) async {
    final model = _settings.getAiModel() ?? 'gemini-1.5-flash';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1000},
    });

    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'API returned status ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response generated by AI model.');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Empty parts in AI response.');
    }

    return parts.first['text'] as String? ?? '';
  }

  // ==========================================
  // JSON Helpers
  // ==========================================
  List<String> _parseJsonArray(String text) {
    var cleaned = text.trim();
    // Strip markdown code fences if present
    if (cleaned.startsWith('```')) {
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      }
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Fallback manual regex match for brackets
      final match = RegExp(r'\[([\s\S]*?)\]').firstMatch(text);
      if (match != null) {
        try {
          final decoded = jsonDecode(match.group(0)!);
          if (decoded is List) {
            return decoded
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (_) {}
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _parseJsonObjectList(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      }
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return [];
  }

  // ==========================================
  // Rule-based Deterministic Fallbacks
  // ==========================================
  List<String> _fallbackExtractChecklist(String text) {
    final List<String> extracted = [];

    // Split text into tokens / clauses by commas, semicolons, bullets, and newlines
    final segments = text
        .split(
          RegExp(r'[\r\n,;•\-\*\.]+|and\s+(?=[a-z])', caseSensitive: false),
        )
        .map((s) => s.trim())
        .where((s) => s.length > 2)
        .toList();

    for (var segment in segments) {
      // Clean leading conversational text
      segment = segment
          .replaceAll(
            RegExp(
              r'^(applicants must provide|must have|including|provide a valid|provide a|provide|a valid|a)\s+',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (segment.isEmpty) continue;

      // Check for quantity (e.g., "two recommendation letters" or "2 recommendation letters")
      final numberMatch = RegExp(
        r'^(two|2|three|3)\s+(.*)',
        caseSensitive: false,
      ).firstMatch(segment);
      if (numberMatch != null) {
        final count =
            (numberMatch.group(1)!.toLowerCase() == 'two' ||
                numberMatch.group(1) == '2')
            ? 2
            : 3;
        var itemName = numberMatch.group(2)!.trim();
        // remove plural 's' at the end if present
        if (itemName.endsWith('s')) {
          itemName = itemName.substring(0, itemName.length - 1);
        }
        final capitalized = _capitalize(itemName);
        for (int i = 1; i <= count; i++) {
          extracted.add('$capitalized $i');
        }
      } else {
        extracted.add(_capitalize(segment));
      }
    }

    return extracted.isEmpty ? [text.trim()] : extracted;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (word.toUpperCase() == 'CV' ||
              word.toUpperCase() == 'IELTS' ||
              word.toUpperCase() == 'TOEFL') {
            return word.toUpperCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  List<AiPriorityItem> _fallbackPriority(List<Map<String, dynamic>> apps) {
    final sorted = List<Map<String, dynamic>>.from(apps);

    // Rule-based sorting: nearest deadline first (including overdue), then lowest progress
    sorted.sort((a, b) {
      final daysA = a['daysRemaining'] as int? ?? 0;
      final daysB = b['daysRemaining'] as int? ?? 0;
      if (daysA != daysB) return daysA.compareTo(daysB);

      final progA = a['progressPercent'] as int? ?? 0;
      final progB = b['progressPercent'] as int? ?? 0;
      return progA.compareTo(progB);
    });

    final List<AiPriorityItem> items = [];
    for (int i = 0; i < sorted.length; i++) {
      final app = sorted[i];
      final days = app['daysRemaining'] as int? ?? 0;
      final prog = app['progressPercent'] as int? ?? 0;
      final remaining = app['remainingRequirements'] as int? ?? 0;
      final name = app['name'] as String? ?? 'Scholarship';

      String reason;
      if (days < 0) {
        reason =
            'Overdue by ${days.abs()} days with $remaining requirements remaining. Take action immediately.';
      } else if (days == 0) {
        reason =
            'Due today! Prioritize remaining documents to finalize before the deadline closes.';
      } else if (days <= 7) {
        reason =
            'Urgent: only $days days left and $remaining requirements incomplete. Focus on this application now.';
      } else if (prog < 50) {
        reason =
            'Deadline in $days days with $prog% progress. Begin preparing essential documents early.';
      } else {
        reason =
            'Well underway ($prog% complete). Review final requirements ahead of the $days-day deadline.';
      }

      items.add(
        AiPriorityItem(
          rank: i + 1,
          scholarshipName: name,
          reason: reason,
          daysRemaining: days,
          progressPercent: prog,
          scholarshipId: app['id'] as int?,
        ),
      );
    }
    return items;
  }

  String _fallbackSummary(List<Map<String, dynamic>> apps) {
    if (apps.isEmpty) {
      return 'You currently have no active applications. Add a scholarship to begin planning!';
    }

    final count = apps.length;
    // Find most urgent (lowest daysRemaining)
    final sorted = List<Map<String, dynamic>>.from(apps);
    sorted.sort(
      (a, b) => (a['daysRemaining'] as int? ?? 0).compareTo(
        b['daysRemaining'] as int? ?? 0,
      ),
    );

    final mostUrgent = sorted.first;
    final urgentName = mostUrgent['name'] as String? ?? 'your scholarship';
    final urgentDays = mostUrgent['daysRemaining'] as int? ?? 0;
    final urgentRemaining = mostUrgent['remainingRequirements'] as int? ?? 0;

    String urgentClause;
    if (urgentDays < 0) {
      urgentClause =
          '$urgentName is overdue with $urgentRemaining requirements remaining';
    } else if (urgentDays == 0) {
      urgentClause =
          '$urgentName is due today with $urgentRemaining requirements remaining';
    } else {
      urgentClause =
          '$urgentName is your most urgent application, due in $urgentDays days with $urgentRemaining requirements remaining';
    }

    return 'You have $count active ${count == 1 ? "application" : "applications"}. $urgentClause. Focus on completing your highest priority documents first to stay on schedule.';
  }
}
