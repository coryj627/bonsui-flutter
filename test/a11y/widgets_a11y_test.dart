// Accessibility audit of the widget catalogue (flutter_a11y_test, layer "runtime"), on
// this fork only: dogfood of https://github.com/coryj627/flutter-a11y.
//
// bonsui ships no example app, so each widget is pumped on its own, built the way
// docs/widgets/*.md shows it, inside a MaterialApp. Findings are RECORDED, not
// asserted: the RuntimeFindingsSink in test/flutter_test_config.dart writes them to
// .a11y/flutter/runtime-findings.json and `a11y_check_flutter scan` decides, against
// the committed baseline, what fails CI.
import 'package:bonsui/bonsui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_a11y_test/flutter_a11y_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _audit(WidgetTester tester, String screenId, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  await tester.binding.setSurfaceSize(const Size(390, 844));
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
  // No settle pump: auditScreen settles whatever the first frame started.
  final result = await auditScreen(tester, screenId: screenId);
  // ignore: avoid_print
  print('a11y $screenId: ${result.findings.length} finding(s)');
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  final widgets = <String, Widget Function()>{
    'button': () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BonsuiButton(label: 'Save', onPressed: () {}),
            BonsuiButton(icon: BonsuiIcons.close, onPressed: () {}),
            BonsuiButton(
              label: 'Cancel',
              icon: BonsuiIcons.close,
              type: BonsuiButtonType.outlined,
              onPressed: () {},
            ),
          ],
        ),
    'text-field': () => BonsuiTextField(
          controller: TextEditingController(),
          placeholder: '123',
          label: 'Phone number',
          prefixIcon: BonsuiIcons.phone,
        ),
    'checkbox': () =>
        BonsuiCheckbox(label: 'Try me!', checked: true, onChanged: (_) {}),
    'switch': () =>
        BonsuiSwitch(label: 'Try me!', checked: true, onChanged: (_) {}),
    'slider': () =>
        BonsuiSlider(value: 20, min: 10, max: 100, onChanged: (_) {}),
    'radio': () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BonsuiRadio(
              value: 'one',
              groupValue: 'one',
              label: 'Option One',
              onChanged: (_) {},
            ),
            BonsuiRadio(
              value: 'two',
              groupValue: 'one',
              label: 'Option Two',
              onChanged: (_) {},
            ),
          ],
        ),
    'badge': () => BonsuiBadge(
          label: 'I am a badge',
          icon: BonsuiIcons.phone,
          color: BonsuiDesign.successColor,
        ),
    'card': () => BonsuiCard(
          title: 'Card title',
          description: 'Look how amazing this card is!',
          icon: BonsuiIcons.phone,
          onPressed: () {},
        ),
    'heading': () => const BonsuiHeading('Hello world'),
    'link': () => const BonsuiLink(
          label: 'Open our website',
          url: 'https://example.com',
          openInExternalBrowser: true,
        ),
    'divider': () => const BonsuiDivider(label: 'Label'),
    'rating': () => BonsuiRating(rating: 2, max: 6, onTap: (_) {}),
    'stepper': () =>
        BonsuiStepper(totalSteps: 5, currentStep: 1, onStepChange: (_) {}),
    'toggle-buttons': () => BonsuiToggleButtons(
          options: [
            BonsuiToggleButtonsItem(icon: BonsuiIcons.home),
            BonsuiToggleButtonsItem(icon: BonsuiIcons.settings),
            BonsuiToggleButtonsItem(icon: BonsuiIcons.person),
          ],
        ),
    'app-bar': () => const Scaffold(appBar: BonsuiAppBar(title: 'Hello')),
    'bottom-navigation-bar': () => Scaffold(
          bottomNavigationBar: BonsuiBottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: [
              BonsuiBottomNavigationBarItem(
                  icon: BonsuiIcons.home, label: 'Home'),
              BonsuiBottomNavigationBarItem(
                icon: BonsuiIcons.settings,
                label: 'Settings',
              ),
            ],
          ),
        ),
  };
  for (final entry in widgets.entries) {
    testWidgets(entry.key, (tester) async {
      await _audit(tester, entry.key, entry.value());
    });
  }
}
