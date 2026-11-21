import 'package:flutter_test/flutter_test.dart';
import 'package:nogueira_gestao/main.dart';

void main() {
  testWidgets('apresenta o painel da Nogueira Gestão', (tester) async {
    await tester.pumpWidget(const NogueiraGestaoApp());
    expect(find.text('NOGUEIRA GESTÃO'), findsOneWidget);
    expect(find.text('Nogueira Doces & Salgados'), findsOneWidget);
  });
}
