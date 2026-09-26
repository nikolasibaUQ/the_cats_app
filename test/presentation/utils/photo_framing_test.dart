import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/presentation/utils/photo_framing.dart';

void main() {
  test('frames a photo with its own proportion', () {
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: 1600,
        height: 1200,
      )),
      closeTo(4 / 3, 0.001),
    );
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: 900,
        height: 1200,
      )),
      closeTo(3 / 4, 0.001),
    );
  });

  test('keeps the extremes of the live breed list inside the band', () {
    // The live breed list reports primary photos from 0.63 to 1.93, which a
    // frame may follow only up to the band: past it the area would resize far
    // more than the photo needs.
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: 630,
        height: 1000,
      )),
      minPhotoAspect,
    );
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: 1930,
        height: 1000,
      )),
      maxPhotoAspect,
    );
  });

  test('falls back when the response does not state the size', () {
    expect(framedPhotoAspect(null), defaultPhotoAspect);
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: null,
        height: null,
      )),
      defaultPhotoAspect,
    );
    // An unusable size is unknown, not a shape to divide by.
    expect(
      framedPhotoAspect((
        url: 'https://example.com/cat.jpg',
        width: 0,
        height: 1200,
      )),
      defaultPhotoAspect,
    );
  });
}
