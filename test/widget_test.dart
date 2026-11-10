import 'package:flutter_test/flutter_test.dart';
import 'package:english_master_academy/main.dart';

void main() {
  testWidgets('La app arranca y muestra el placeholder de bootstrap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EnglishMasterAcademyApp());

    expect(find.text('English Master Academy'), findsOneWidget);
    expect(find.textContaining('Bootstrap OK'), findsOneWidget);
  });
}
