import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipediscovery/core/services/app.dart';

void main() {
  testWidgets('renders recipe discovery app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RecipeDiscoveryApp()));

    expect(find.text('Recipe Discovery'), findsOneWidget);
    expect(find.text('Smart recipes start here'), findsOneWidget);
  });
}
