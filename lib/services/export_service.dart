import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/date_utils.dart';
import '../data/models/scholarship.dart';
import '../data/repositories/requirement_repository.dart';

/// Free-plan data export (§7.8, §17): every application and requirement
/// as one CSV file, shared through the Android share sheet.
class ExportService {
  ExportService._();

  static String _cell(Object? value) {
    final text = (value ?? '').toString();
    if (text.contains(RegExp(r'[",\n\r]'))) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  static Future<String> buildCsv(List<Scholarship> scholarships) async {
    final reqRepo = RequirementRepository();
    final buffer = StringBuffer()
      ..writeln([
        'Scholarship',
        'Country',
        'Deadline',
        'Days left',
        'Status',
        'Link',
        'Notes',
        'Requirement',
        'Requirement done',
      ].join(','));

    for (final s in scholarships) {
      final base = [
        s.name,
        s.country,
        s.deadline,
        AppDateUtils.daysRemaining(s.deadlineDateTime),
        s.status,
        s.link,
        s.notes,
      ];
      final reqs = await reqRepo.getForScholarship(s.id);
      if (reqs.isEmpty) {
        buffer.writeln([...base, '', ''].map(_cell).join(','));
      } else {
        for (final r in reqs) {
          buffer.writeln(
            [...base, r.title, r.isDone ? 'Yes' : 'No'].map(_cell).join(','),
          );
        }
      }
    }
    return buffer.toString();
  }

  /// Writes the CSV to a temporary file and opens the share sheet.
  /// Returns the file path.
  static Future<String> exportAndShare(List<Scholarship> scholarships) async {
    final csv = await buildCsv(scholarships);
    final dir = await getTemporaryDirectory();
    final stamp = AppDateUtils.formatIso(DateTime.now());
    final file = File('${dir.path}/dossier_export_$stamp.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Dossier export $stamp',
    );
    return file.path;
  }
}
