import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iconos_demo/main.dart';

void main() {
  testWidgets('la app usa tema oscuro y permite agregar contactos', (
    tester,
  ) async {
    await tester.pumpWidget(const SocialDemoApp());

    expect(Theme.of(tester.element(find.byType(HomePage))).brightness,
        Brightness.dark);
    expect(find.text('Sofia Ramirez'), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar contacto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana Lopez');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Lopez'), findsOneWidget);
  });

  testWidgets('permite crear una conversacion con un contacto', (tester) async {
    await tester.pumpWidget(const SocialDemoApp());
    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Chats'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Nueva conversacion'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Person>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucia Morales').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Lucia Morales'), findsOneWidget);
    expect(find.text('Nueva conversacion'), findsOneWidget);
  });
}
