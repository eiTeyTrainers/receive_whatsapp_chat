import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';

void main() {
  const MethodChannel channel = MethodChannel('receive_whatsapp_chat');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ReceiveWhatsappChat.platformVersion, '42');
  });
}
