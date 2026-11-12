import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:english_master_academy/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renderiza 2 campos y el botón Entrar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
