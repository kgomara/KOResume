package com.kevingomara.koresume;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class AboutActivity extends Activity {

	private static final String TAG = "AboutActivity";
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.about_layout);
        
        Log.v(TAG, "onCreate() called");
    }
}
