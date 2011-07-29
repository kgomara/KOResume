package com.kevingomara.koresume;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

public class SaveAccomplishmentActivity extends Activity {
	private static final String TAG = "SaveAccomplishmentsActivity";
	private static Long	mJobId		= 0l;
	
	// references to the fields in the layout
	private EditText	mAccName	= null;
	private EditText	mAccSummary	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.edit_accomplishment);
        
        Log.v(TAG, "onCreate() called");
        
        // Get the Job Id passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mJobId = extras.getLong("id");
        Log.v(TAG, "jobId = " + mJobId);
        
        // Get the ListView and register it for a context menu
        mAccName	= (EditText) findViewById(R.id.accName);
        mAccSummary	= (EditText) findViewById(R.id.accSummary);
    }
    
    /**
     * User decided to cancel the edit - finish the activity and return to caller.
     * 
     * @param view
     */
    public void onCancelBtn(View view) {
    	
    	this.finish();
    }
    
    /**
     * Save the updated accomplishment to the db
     * 
     * @param view
     */
    public void onSaveBtn(View view) {
    	saveAccomplishment();
    	this.finish(); 
    }
    
    private void saveAccomplishment() {
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(AccomplishmentsTableMetaData.NAME,	mAccName.getText().toString());
		contentValues.put(AccomplishmentsTableMetaData.SUMMARY,	mAccSummary.getText().toString());
		contentValues.put(AccomplishmentsTableMetaData.JOBS_ID, mJobId.toString());
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = KOResumeProviderMetaData.AccomplishmentsTableMetaData.CONTENT_URI;
		contentResolver.insert(uri, contentValues);
    }
}
