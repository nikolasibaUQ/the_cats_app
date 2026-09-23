import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/shared/responsive.dart';

void main() {
  test('keeps viewport measurements and visual scales bounded', () {
    const phone = Responsive.fromSize(Size(320, 568));
    const desktop = Responsive.fromSize(Size(1440, 900));
    const ultrawide = Responsive.fromSize(Size(3440, 1440));

    expect(phone.wp(50), 160);
    expect(phone.hp(25), 142);
    expect(phone.isTablet, isFalse);
    expect(phone.isDesktop, isFalse);
    expect(phone.spacing(20), 18);
    expect(desktop.isDesktop, isTrue);
    expect(desktop.spacing(20), 22);
    expect(ultrawide.fpw(20), lessThanOrEqualTo(23));
    expect(ultrawide.fp(20), lessThanOrEqualTo(23));
  });
}
