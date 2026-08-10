import 'package:flutter_test/flutter_test.dart';
import 'package:casa_em_ordem/main.dart';

void main() {
  testWidgets('Verifica a renderização da navegação principal do Casa em Ordem', (WidgetTester tester) async {
    await tester.pumpWidget(const CasaEmOrdemApp());
    expect(find.text('Tarefas'), findsWidgets);
    expect(find.text('Ranking'), findsWidgets);
    expect(find.text('Histórico'), findsWidgets);
    expect(find.text('Ajustes'), findsWidgets);
  });
}
