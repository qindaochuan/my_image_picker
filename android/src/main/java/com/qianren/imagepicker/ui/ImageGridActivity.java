package com.qianren.imagepicker.ui;

import android.app.Activity;
import android.os.Bundle;

import com.qianren.my_image_picker.R;

public class ImageGridActivity extends Activity {
    public static final String EXTRAS_IMAGES = "IMAGES";
    public static final int REQUEST_PERMISSION_CAMERA = 0x02;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_grid);
    }
}
