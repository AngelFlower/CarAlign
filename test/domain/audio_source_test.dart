import 'package:caralign/domain/entities/audio_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AudioSourceKind kind(String? out) => AudioSource.parse(out).kind;

  test('recognizes Android Auto by remote-submix or type 25', () {
    expect(kind('25:remote-submix'), AudioSourceKind.androidAuto);
    expect(kind('remote-submix'), AudioSourceKind.androidAuto);
  });

  test('recognizes Bluetooth by name or type', () {
    expect(kind('8:Car A2DP'), AudioSourceKind.bluetooth);
    expect(kind('7:Hands-free'), AudioSourceKind.bluetooth);
    expect(kind('Bluetooth speaker'), AudioSourceKind.bluetooth);
  });

  test('recognizes the phone speaker and USB', () {
    expect(kind('2:Pixel 6'), AudioSourceKind.phoneSpeaker);
    expect(kind('11:USB headset'), AudioSourceKind.usb);
  });

  test('empty and odd descriptors', () {
    expect(kind(null), AudioSourceKind.unknown);
    expect(kind('  '), AudioSourceKind.unknown);
    expect(kind('99:mystery'), AudioSourceKind.unrecognized);
  });
}
