import 'package:flutter_test/flutter_test.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/plates.dart';

void main() {
  group('Plates.forTotal (kg)', () {
    test('an empty 20 kg bar is bar-only', () {
      final load = Plates.forTotal(20, unit: WeightUnit.kg)!;
      expect(load.perSide, isEmpty);
      expect(load.isBarOnly, isTrue);
      expect(Plates.describe(load), 'Bar only');
    });

    test('100 kg is 40 a side, taken greedily as 25 + 15', () {
      final load = Plates.forTotal(100, unit: WeightUnit.kg)!;
      expect(load.perSide, [25, 15]);
      expect(load.isExact, isTrue);
      expect(Plates.describe(load), '25 + 15');
    });

    test('greedy fit uses the fewest plates', () {
      // 82.5 → 31.25 per side → 25 + 5 + 1.25
      final load = Plates.forTotal(82.5, unit: WeightUnit.kg)!;
      expect(load.perSide, [25, 5, 1.25]);
      expect(load.isExact, isTrue);
    });

    test('reports what it cannot make up', () {
      // 21 kg → 0.5 per side, smaller than the smallest plate.
      final load = Plates.forTotal(21, unit: WeightUnit.kg)!;
      expect(load.perSide, isEmpty);
      expect(load.isExact, isFalse);
      expect(load.leftoverKg, closeTo(1.0, 0.001));
    });

    test('below the bar there is nothing to load', () {
      expect(Plates.forTotal(15, unit: WeightUnit.kg), isNull);
    });
  });

  group('Plates.forTotal (lb)', () {
    test('plates come out in pounds, not converted kilos', () {
      // 135 lb on a 45 lb bar → 45 per side.
      final load = Plates.forTotal(WeightUnit.lb.toKg(135), unit: WeightUnit.lb)!;
      expect(load.perSide, [45]);
      expect(load.isExact, isTrue);
      expect(Plates.describe(load), '45');
    });

    test('225 lb is 45 + 45 per side', () {
      final load = Plates.forTotal(WeightUnit.lb.toKg(225), unit: WeightUnit.lb)!;
      expect(load.perSide, [45, 45]);
    });
  });

  test('describe trims trailing zeros', () {
    final load = Plates.forTotal(45, unit: WeightUnit.kg)!;
    // 12.5 per side → 10 + 2.5
    expect(Plates.describe(load), '10 + 2.5');
  });
}
