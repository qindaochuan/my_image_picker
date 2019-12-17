package com.qianren.my_image_picker;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.provider.MediaStore;

import androidx.core.content.FileProvider;

import com.qianren.imagepicker.bean.ImageItem;
import com.qianren.imagepicker.ui.ImageGridActivity;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class MyImagePickerDelegate implements PluginRegistry.ActivityResultListener{
    private final Activity activity;
    private Handler handler = null;

    private double maxWidth;
    private double maxHeight;
    private int imageQuality;
    MethodChannel.Result result;
    private String savePath = null;

    private File mCurrentFile = null;

    //裁切图片是否发生错误
    private boolean isClipErrorFlag = false;

    private ArrayList<ImageItem> images = null;

    private static final int HANDLER_SELECT_CAMERA_IMAGE = 1;
    private static final int HANDLER_SELECT_ALBUM_IMAGE = 2;
    private static final int HANDLER_CIRCLE_CROP = 3;

    private static final int CAMERA_WITH_DATA = 3023;
    private static final int PHOTO_PICKED_WITH_DATA = 3021;
    private static final int CUT_OK = 3022;

    public MyImagePickerDelegate(Activity activity) {
        this.activity = activity;
        this.handler = new MyHandler(activity, this);

        //初始化文件
        File dirFile = activity.getExternalFilesDir(null);
        if (dirFile != null && !dirFile.exists()) {
            dirFile.mkdirs();
        }
        mCurrentFile = new File(dirFile, "temp.jpg");
        mCurrentFile.delete();
    }

    public void selectCameraImage(MethodCall call, MethodChannel.Result result) {
        this.result = result;
        double maxWidth = call.argument("maxWidth");
        double maxHeight = call.argument("maxHeight");
        int imageQuality = call.argument("imageQuality");
        System.out.println("Call Java selectCameraImage");
        System.out.println(String.format("maxWidth = %s maxHeight = %s imageQuality = %d", maxHeight, maxHeight, imageQuality));
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
        this.imageQuality = imageQuality;
        isClipErrorFlag = false;
        Message msg = new Message();
        msg.what = HANDLER_SELECT_CAMERA_IMAGE;
        handler.sendMessage(msg);
    }

    public void selectAlbumImage(MethodCall call, MethodChannel.Result result) {
        this.result = result;
        double maxWidth = call.argument("maxWidth");
        double maxHeight = call.argument("maxHeight");
        int imageQuality = call.argument("imageQuality");
        System.out.println("Call Java selectAlbumImage");
        System.out.println(String.format("maxWidth = %s maxHeight = %s imageQuality = %d", maxHeight, maxHeight, imageQuality));
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
        this.imageQuality = imageQuality;
        isClipErrorFlag = false;
        Message msg = new Message();
        msg.what = HANDLER_SELECT_ALBUM_IMAGE;
        handler.sendMessage(msg);
    }

    public void circleCrop(MethodCall call, MethodChannel.Result result) {
        this.result = result;
        double maxWidth = call.argument("maxWidth");
        double maxHeight = call.argument("maxHeight");
        int imageQuality = call.argument("imageQuality");
        System.out.println("Call Java circleCrop");
        System.out.println(String.format("maxWidth = %s maxHeight = %s imageQuality = %d", maxHeight, maxHeight, imageQuality));
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
        this.imageQuality = imageQuality;
        isClipErrorFlag = false;
        Message msg = new Message();
        msg.what = HANDLER_CIRCLE_CROP;
        handler.sendMessage(msg);
    }

    public static class MyHandler extends Handler {
        WeakReference<Activity> mActivity;
        WeakReference<MyImagePickerDelegate> mInstance;

        MyHandler(Activity activity, MyImagePickerDelegate instance) {
            mActivity = new WeakReference<>(activity);
            mInstance = new WeakReference<>(instance);
        }

        public void handleMessage(Message msg) {
            //Activity theActivity = mActivity.get();
            MyImagePickerDelegate theInstance = mInstance.get();
            switch (msg.what) {
                case HANDLER_SELECT_CAMERA_IMAGE:
                    theInstance.doSelectCameraImage();
                    break;
                case HANDLER_SELECT_ALBUM_IMAGE:
                    theInstance.doSelectAlbumImage();
                    break;
                case HANDLER_CIRCLE_CROP:
                    theInstance.doCircleCrop();
                    break;
            }
        }
    }

    public void doSelectCameraImage() {
        new Thread()
        {
            public void run()
            {
                Looper.prepare();
                try {
                    Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                    System.out.println(("mCurrentFile: " + mCurrentFile));
                    Uri photoOutputUri = FileProvider.getUriForFile(activity,"com.qianren.my_image_picker.MyImagePickerFileProvider",mCurrentFile);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        cameraIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); //添加这一句表示对目标应用临时授权该Uri所代表的文件
                    }
                    cameraIntent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, photoOutputUri);
                    activity.startActivityForResult(cameraIntent, CAMERA_WITH_DATA);
                } catch (Exception e) {
                    // TODO 自动生成的 catch 块
                    e.printStackTrace();
                }
                Looper.loop();
            }
        }.start();
    }

    public void doSelectAlbumImage() {
        new Thread() {
            public void run() {
                Looper.prepare();
                try {
                    Intent albumIntent = new Intent(Intent.ACTION_PICK,
                            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                    //Intent albumIntent = new Intent(Intent.ACTION_PICK, null);
                    albumIntent.setDataAndType(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
                    activity.startActivityForResult(albumIntent, PHOTO_PICKED_WITH_DATA);
                } catch (Exception e) {
                    // TODO 自动生成的 catch 块
                    e.printStackTrace();
                }
                Looper.loop();
            }
        }.start();
    }

    public void doCircleCrop() {
        new Thread() {
            public void run() {
                Looper.prepare();
                try {
                    Intent intent = new Intent(activity, ImageGridActivity.class);
                    intent.putExtra(ImageGridActivity.EXTRAS_IMAGES,images);
                    //ImagePicker.getInstance().setSelectedImages(images);
                    activity.startActivityForResult(intent, 100);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Looper.loop();
            }
        }.start();
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        System.out.println("MyImagePickerDelegate: " + "onActivityResult");
        if( requestCode == PHOTO_PICKED_WITH_DATA) {
            if (data != null) {
                clipPhoto(data.getData());
            }
        }
        else if (requestCode == CAMERA_WITH_DATA) {
            if (mCurrentFile.exists()) {
                Uri photoOutputUri = FileProvider.getUriForFile(activity,"com.qianren.my_image_picker.MyImagePickerFileProvider",mCurrentFile);
                clipPhoto(photoOutputUri);// ��ʼ�ü�ͼƬ
            }

        }
        else if(requestCode == CUT_OK) {
            if (data != null) {
                //裁切图片是否发生错误
                if (isClipErrorFlag == false) {
                    //setPicToView(data);
                    Handler thisHandler = new Handler(Looper.getMainLooper());
                    thisHandler.post(new Runnable()
                    {
                        @Override
                        public void run()
                        {
                            result.success(mCurrentFile.getAbsolutePath());
                        }
                    });
                }
            }
        }
        else{
            return false;
        }
        return true;
    }

    public void clipPhoto(Uri uri) {
        System.out.println("clipPhoto uri: "+ uri);
        try {
            Intent intent = new Intent("com.android.camera.action.CROP");
            intent.setDataAndType(uri, "image/*");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); //添加这一句表示对目标应用临时授权该Uri所代表的文件
            }
            intent.putExtra("crop", "true");
            intent.putExtra("aspectX", 1);
            intent.putExtra("aspectY", 1);
            intent.putExtra("outputX", 600);
            intent.putExtra("outputY", 600);
            intent.putExtra("scale", true);
            intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(mCurrentFile));
            intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
            intent.putExtra("return-data", false);
            intent.putExtra("circleCrop", true);//圆形裁切
            activity.startActivityForResult(intent, CUT_OK);
        } catch (Exception e) {
            // TODO 自动生成的 catch 块
            e.printStackTrace();
            //裁切图片发生错误的标志
            isClipErrorFlag = true;
        }
    }

    private Bitmap decodeUriAsBitmap(Uri uri){
        System.out.println("setPicToView uri: "+ uri);
        Bitmap bitmap = null;
        try {
            bitmap = BitmapFactory.decodeStream(activity.getContentResolver().openInputStream(uri));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        }
        return bitmap;
    }

    public void setPicToView(Intent picdata) {
        Handler thisHandler = new Handler(Looper.getMainLooper());
        thisHandler.post(new Runnable()
        {
            @Override
            public void run()
            {
                if (mCurrentFile != null) {
                    Bitmap photo = decodeUriAsBitmap(Uri.fromFile(mCurrentFile));
                    if(photo != null){
                        try {
                            FileOutputStream bgOutput = new FileOutputStream(new File(savePath));
                            photo.compress(Bitmap.CompressFormat.JPEG, 75, bgOutput);
                            int width = photo.getWidth();
                            int height = photo.getHeight();
                            bgOutput.flush();
                            bgOutput.close();
                            //super.onResume();
                            //runNativeCallback(_luaFunctionId,_savePath,width,height);

                            //Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_luaFunctionId,_savePath+","+Integer.toString(width)+","+Integer.toString(height));
                            //Cocos2dxLuaJavaBridge.releaseLuaFunction(_luaFunctionId);
                        } catch (FileNotFoundException e) {
                            e.printStackTrace();
                        }catch (IOException e) {
                            e.printStackTrace();
                        }catch (Exception e) {
                            // TODO 自动生成的 catch 块
                            e.printStackTrace();
                        }
                    }
                    else{
                        //mCurrentFile.delete();
                    }
                }
            }
        });
    }
}
