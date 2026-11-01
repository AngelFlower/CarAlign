import 'package:caralign/domain/entities/alignment_result.dart';
import 'package:caralign/domain/entities/guard_status.dart';
import 'package:caralign/i18n/strings.g.dart';
import 'package:caralign/presentation/localization/domain_l10n.dart';
import 'package:caralign/core/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() async => LocaleSettings.setLocale(AppLocale.en));

  test('result messages carry their reason and values in English', () async {
    await LocaleSettings.setLocale(AppLocale.en);
    const m = ResultMessage(ResultMessageCode.measurementUnreliable, reason: Reason(ReasonCode.fewValidReps, 3));
    expect(m.localized, 'The measurement was not reliable: too few valid repetitions (3).');
  });

  test('the same message in Spanish', () async {
    await LocaleSettings.setLocale(AppLocale.es);
    const m = ResultMessage(ResultMessageCode.notConverging, value: 120);
    expect(m.localized, 'El ajuste no converge del todo; queda un residuo de 120 µs.');
  });

  test('decimal separator follows the locale', () async {
    await LocaleSettings.setLocale(AppLocale.en);
    expect(formatMs(1.1), '1.1');
    await LocaleSettings.setLocale(AppLocale.es);
    expect(formatMs(1.1), '1,1');
    expect(formatMs(1.08), '1,08');
    expect(formatMs(2), '2');
  });

  test('guard details with an argument', () async {
    await LocaleSettings.setLocale(AppLocale.en);
    expect(const GuardDetail(GuardDetailCode.shizukuFailed, 'denied').text, 'Shizuku is active but failed: denied');
  });

  test('both locales define the same keys', () async {
    // Slang fails the build on missing keys; this guards the generated classes staying in sync.
    expect(AppLocale.values, containsAll([AppLocale.en, AppLocale.es]));
  });
}
