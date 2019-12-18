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
      //focusWidth 裁剪框的宽度。单位像素（圆形自动取宽高最小值）
      //focusHeight 裁剪框的高度。单位像素（圆形自动取宽高最小值）
      //outPutX 保存文件的宽度。单位像素
      //outPutY 保存文件的高度。单位像素
      {int focusWidth = 800, int focusHeight = 800, int outPutX = 1000,int outPutY = 1000}) async {

    final String path = await _channel.invokeMethod<String>(
      'circleCrop',
      <String, dynamic>{
        'focusWidth': focusWidth,
        'focusHeight': focusHeight,
        'outPutX': outPutX,
        'outPutY': outPutY,
      },
    );

    return path;
  }
}
