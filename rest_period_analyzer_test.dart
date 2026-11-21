import 'package:flutter_test/flutter_test.dart';
import 'package:tacocontrol_pro/features/break_rest/rest_period_analyzer.dart';
import 'package:tacocontrol_pro/features/tachograph/tachograph_activity.dart';

void main() {
  final start = DateTime(2026, 10, 1, 20);
  TachographActivity rest(Duration duration, {String type = 'rest'}) => TachographActivity(start:start,end:start.add(duration),type:type,source:'test');
  test('classifica descanso diário normal explícito', () {
    final r = RestPeriodAnalyzer().analyze([rest(const Duration(hours:11))]);
    expect(r.daily.single.level, RestPeriodLevel.normal);
  });
  test('classifica descanso diário reduzido sem o declarar automaticamente legal', () {
    final r = RestPeriodAnalyzer().analyze([rest(const Duration(hours:9, minutes:30))]);
    expect(r.daily.single.level, RestPeriodLevel.reduced);
    expect(r.daily.single.detail, contains('frequência'));
  });
  test('classifica descanso semanal reduzido explícito', () {
    final r = RestPeriodAnalyzer().analyze([rest(const Duration(hours:24), type:'weekly_rest')]);
    expect(r.weekly.single.level, RestPeriodLevel.reduced);
  });
  test('não transforma lacuna em descanso', () {
    final a = DateTime(2026,10,1,8);
    final r = RestPeriodAnalyzer().analyze([
      TachographActivity(start:a,end:a.add(const Duration(hours:2)),type:'driving',source:'test'),
      TachographActivity(start:a.add(const Duration(hours:14)),end:a.add(const Duration(hours:15)),type:'driving',source:'test'),
    ]);
    expect(r.daily,isEmpty);
    expect(r.unclassifiedGaps,1);
  });
}
