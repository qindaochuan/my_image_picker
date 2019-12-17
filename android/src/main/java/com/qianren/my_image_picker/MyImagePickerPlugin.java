package com.qianren.my_image_picker;

import android.os.Build;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** MyImagePickerPlugin */
public class MyImagePickerPlugin implements MethodCallHandler {
  private static final String CHANNEL = "plugins.flutter.io/my_image_picker";
  private final PluginRegistry.Registrar registrar;
  private MyImagePickerDelegate delegate;

  MyImagePickerPlugin(final PluginRegistry.Registrar registrar, final MyImagePickerDelegate delegate) {
    this.registrar = registrar;
    this.delegate = delegate;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background flutter view tries to register the plugin, there will be no activity from the registrar,
      // we stop the registering process immediately because the ImagePicker requires an activity.
      return;
    }

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    final MyImagePickerDelegate delegate =
            new MyImagePickerDelegate(registrar.activity());

    registrar.addActivityResultListener(delegate);

    final MyImagePickerPlugin instance = new MyImagePickerPlugin(registrar, delegate);
    channel.setMethodCallHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result rawResult) {
    if (call.method.equals("selectCameraImage")) {
      delegate.selectCameraImage(call,rawResult);
    } else if(call.method.equals("selectAlbumImage")) {

      delegate.selectAlbumImage(call,rawResult);
    }
    else if(call.method.equals("circleCrop")) {

      delegate.circleCrop(call,rawResult);
    }
    else {
      rawResult.notImplemented();
    }
  }
}
