import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/social/social_repository.dart';

void main() {
  group('SocialRepository.suggestHandle', () {
    test('uses the email local part, lowercased and cleaned', () {
      expect(
        SocialRepository.suggestHandle(email: 'Imran.Jeferly@gmail.com'),
        'imran_jeferly',
      );
      expect(SocialRepository.suggestHandle(email: 'a-b--c@x.io'), 'a_b_c');
    });

    test('falls back to the name, then to lifter', () {
      expect(SocialRepository.suggestHandle(name: 'Big Mike'), 'big_mike');
      expect(SocialRepository.suggestHandle(email: 'ab@x.io'), 'lifter');
      expect(SocialRepository.suggestHandle(), 'lifter');
    });

    test('leaves room for a numeric suffix', () {
      final h = SocialRepository.suggestHandle(
        email: 'averyveryverylongaddress@x.io',
      );
      expect(h.length, lessThanOrEqualTo(16));
      expect(RegExp(r'^[a-z0-9_]{3,16}$').hasMatch(h), isTrue);
    });
  });
}
