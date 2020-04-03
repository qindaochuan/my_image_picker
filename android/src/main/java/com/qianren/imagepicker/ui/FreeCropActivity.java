package com.qianren.imagepicker.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;

import com.isseiaoki.simplecropview.FreeCropImageView;
import com.isseiaoki.simplecropview.callback.CropCallback;
import com.isseiaoki.simplecropview.callback.LoadCallback;
import com.isseiaoki.simplecropview.callback.SaveCallback;
import com.isseiaoki.simplecropview.util.Logger;
import com.qianren.imagepicker.ImagePicker;
import com.qianren.imagepicker.bean.ImageItem;
import com.qianren.my_image_picker.R;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import static android.os.Environment.DIRECTORY_DOWNLOADS;

public class FreeCropActivity extends ImageBaseActivity implements View.OnClickListener {

    private ArrayList<ImageItem> mImageItems;
    private ImagePicker imagePicker;
    private FreeCropImageView mCropImageView;
    private String mImagePath;
    private Bitmap.CompressFormat mCompressFormat = Bitmap.CompressFormat.JPEG;
    private Uri mSourceUri = null;
    private View mLoadingBox;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_free_crop);

        imagePicker = ImagePicker.getInstance();

        mCropImageView = findViewById(R.id.freeCropImageView);

        findViewById(R.id.btn_back).setOnClickListener(this);
        Button btn_ok = findViewById(R.id.btn_ok);
        btn_ok.setText(getString(R.string.ip_complete));
        btn_ok.setOnClickListener(this);
        mLoadingBox = (View) findViewById(R.id.ip_rl_box);

        mImageItems = imagePicker.getSelectedImages();
        mImagePath = mImageItems.get(0).path;
        mSourceUri = Uri.fromFile(new File(mImagePath));
        mCropImageView.setCropMode(imagePicker.mFreeCropMode);
        mCropImageView.load(mSourceUri)
                .initialFrameScale(0.5f)
                .useThumbnail(true)
                .execute(mLoadCallback);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_back) {
            setResult(RESULT_CANCELED);
            finish();
        } else if (id == R.id.btn_ok) {
            mLoadingBox.setVisibility(View.VISIBLE);
            mCropImageView.crop(mSourceUri).execute(mCropCallback);
        }
    }

    private final LoadCallback mLoadCallback = new LoadCallback() {
        @Override
        public void onSuccess() {
        }

        @Override
        public void onError(Throwable e) {
        }
    };
    private final CropCallback mCropCallback = new CropCallback() {
        @Override
        public void onSuccess(Bitmap cropped) {
            mCropImageView.save(cropped)
                    .compressFormat(mCompressFormat)
                    .execute(createSaveUri(), mSaveCallback);
        }

        @Override
        public void onError(Throwable e) {

            mLoadingBox.setVisibility(View.GONE);
        }
    };
    private final SaveCallback mSaveCallback = new SaveCallback() {
        @Override
        public void onSuccess(Uri outputUri) {
            mLoadingBox.setVisibility(View.GONE);
            mImageItems.remove(0);
            ImageItem imageItem = new ImageItem();
            imageItem.path = outputUri.getPath();
            mImageItems.add(imageItem);
            Intent intent = new Intent();
            intent.putExtra(ImagePicker.EXTRA_RESULT_ITEMS, mImageItems);
            setResult(ImagePicker.RESULT_CODE_ITEMS, intent);
            finish();
        }

        @Override
        public void onError(Throwable e) {
            mLoadingBox.setVisibility(View.GONE);
        }
    };

    public Uri createSaveUri() {
        return createNewUri(this, mCompressFormat);
    }

    public static Uri createNewUri(Context context, Bitmap.CompressFormat format) {
        long currentTimeMillis = System.currentTimeMillis();
        Date today = new Date(currentTimeMillis);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
        String title = dateFormat.format(today);
        String fileName = "scv" + title + "." + getMimeType(format);
        File cropCacheFolder = ImagePicker.getInstance().getCropCacheFolder(context);
        File cropFile = new File(cropCacheFolder,fileName);
        return Uri.fromFile(cropFile);
    }

    public static String getDirPath() {
        String dirPath = "";
        File imageDir = null;
        File extStorageDir = Environment.getExternalStoragePublicDirectory(DIRECTORY_DOWNLOADS);
        if (extStorageDir.canWrite()) {
            imageDir = new File(extStorageDir.getPath() + "/crop_pic");
        }
        if (imageDir != null) {
            if (!imageDir.exists()) {
                imageDir.mkdirs();
            }
            if (imageDir.canWrite()) {
                dirPath = imageDir.getPath();
            }
        }
        return dirPath;
    }

    public static String getMimeType(Bitmap.CompressFormat format) {
        Logger.i("getMimeType CompressFormat = " + format);
        switch (format) {
            case JPEG:
                return "jpeg";
            case PNG:
                return "png";
        }
        return "png";
    }

}
