import 'dart:async';

import 'package:flutter/services.dart';

class MyImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/my_image_picker');

  //调用相机
  static Future<String> selectCameraImage(
      {double maxWidth = 100, double maxHeight = 100, int imageQuality = 75}) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    final String path = await _channel.invokeMethod<String>(
      'selectCameraImage',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality
      },
    );

    return path;
  }

  //取相册内图片
  static Future<String> selectAlbumImage(
      {double maxWidth = 100, double maxHeight = 100, int imageQuality = 75}) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    final String path = await _channel.invokeMethod<String>(
      'selectAlbumImage',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality
      },
    );

    return path;
  }

  //圆形裁剪新开的接口
  static Future<String> circleCrop(
      {double maxWidth = 100, double maxHeight = 100, int imageQuality = 75}) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    final String path = await _channel.invokeMethod<String>(
      'circleCrop',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality
      },
    );

    return path;
  }
}
