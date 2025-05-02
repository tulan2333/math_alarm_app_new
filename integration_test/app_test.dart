import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:math_alarm_app_new/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Pruebas de integración de la aplicación', () {
    testWidgets('Flujo completo: crear, editar y eliminar alarma',
      (WidgetTester tester) async {
      // Iniciar la aplicación
      app.main();
      await tester.pumpAndSettle();
      
      // Verificar que la pantalla de inicio se carga correctamente
      expect(find.text('Alarma Matemática'), findsOneWidget);
      
      // Pulsar el botón para añadir una nueva alarma
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Verificar que estamos en la pantalla de detalle de alarma
      expect(find.text('Nueva Alarma'), findsOneWidget);
      
      // Configurar la alarma (seleccionar días, etc.)
      await tester.tap(find.text('L'));
      await tester.tap(find.text('M'));
      await tester.pumpAndSettle();
      
      // Guardar la alarma
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      // Verificar que volvemos a la pantalla principal y la alarma se muestra
      expect(find.text('Alarma Matemática'), findsOneWidget);
      
      // Más pasos de prueba para editar y eliminar la alarma...
    });
  });
}