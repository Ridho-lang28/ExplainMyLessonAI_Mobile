import 'package:flutter_test/flutter_test.dart';
import 'package:explainmylessonai_mobile/main.dart';

void main() {
  testWidgets('ExplainMyLessonApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExplainMyLessonApp());
    expect(find.byType(ExplainMyLessonApp), findsOneWidget);
  });
}
