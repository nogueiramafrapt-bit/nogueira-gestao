import 'package:flutter_test/flutter_test.dart';
import 'package:tacocontrol_pro/features/break_rest/break_rest_analyzer.dart';
import 'package:tacocontrol_pro/features/tachograph/tachograph_activity.dart';

void main() {
  final start = DateTime(2026, 10, 1, 8);
  test('sem atividades indica dados insuficientes', () {
    final report = BreakRestAnalyzer().analyze(const []);
    expect(report.hasDrivingData, isFalse);
    expect(report.findings.any((f) => f.level == FindingLevel.insufficientData), isTrue);
  });
  test('não considera uma lacuna sem atividade como pausa', () {
    final report = BreakRestAnalyzer().analyze([
      TachographActivity(start: start, end: start.add(const Duration(hours: 2)), type: 'driving', source: 'test'),
      TachographActivity(start: start.add(const Duration(hours: 3)), end: start.add(const Duration(hours: 4)), type: 'driving', source: 'test'),
    ]);
    expect(report.totalBreak, Duration.zero);
    expect(report.unclassifiedGapCount, 1);
    expect(report.findings.any((f) => f.level == FindingLevel.insufficientData), isTrue);
  });
  test('assinala atividades sobrepostas', () {
    final report = BreakRestAnalyzer().analyze([
      TachographActivity(start: start, end: start.add(const Duration(hours: 2)), type: 'driving', source: 'test'),
      TachographActivity(start: start.add(const Duration(hours: 1)), end: start.add(const Duration(hours: 3)), type: 'break', source: 'test'),
    ]);
    expect(report.overlapCount, 1);
    expect(report.findings.any((f) => f.title == 'Atividades sobrepostas'), isTrue);
  });
  test('soma condução e pausas explícitas', () {
    final report = BreakRestAnalyzer().analyze([
      TachographActivity(start: start, end: start.add(const Duration(hours: 2)), type: 'driving', source: 'test'),
      TachographActivity(start: start.add(const Duration(hours: 2)), end: start.add(const Duration(hours: 2, minutes: 45)), type: 'break', source: 'test'),
    ]);
    expect(report.totalDriving, const Duration(hours: 2));
    expect(report.totalBreak, const Duration(minutes: 45));
    expect(report.hasDrivingData, isTrue);
  });
}
