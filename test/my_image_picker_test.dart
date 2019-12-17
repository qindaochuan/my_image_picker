//import 'package:flutter/services.dart';
//import 'package:flutter_test/flutter_test.dart';
//import 'package:my_image_picker/my_image_picker.dart';
//
//void main() {
//  const MethodChannel channel = MethodChannel('my_image_picker');
//
//  setUp(() {
//    channel.setMockMethodCallHandler((MethodCall methodCall) async {
//      return '42';
//    });
//  });
//
//  tearDown(() {
//    channel.setMockMethodCallHandler(null);
//  });
//
//  test('getPlatformVersion', () async {
//    expect(await MyImagePicker.platformVersion, '42');
//  });
//}
