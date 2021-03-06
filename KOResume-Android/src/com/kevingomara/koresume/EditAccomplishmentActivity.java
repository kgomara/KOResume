package com.kevingomara.koresume;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;

public class EditAccomplishmentActivity extends Activity {

	private static final String TAG = "EditAccomplishmentsActivity";
	private static long	 mAccId		= 0;
	
	// references to the fields in the layout
	private EditText	mAccName	= null;
	private EditText	mAccSummary	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.edit_accomplishment);
        
        Log.v(TAG, "onCreate() called");
        
        // Get the Accomplishment Id passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mAccId = extras.getLong("id");
        Log.v(TAG, "accId = " + mAccId);
        
        // Get the ListView and register it for a context menu
        mAccName	= (EditText) findViewById(R.id.accName);
        mAccSummary	= (EditText) findViewById(R.id.accSummary);
        
        // Populate the list of accomplishments
        populateAccomplishment(mAccId);
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
		contentValues.put(AccomplishmentsTableMetaData.NAME,			mAccName.getText().toString());
		contentValues.put(AccomplishmentsTableMetaData.SUMMARY,			mAccSummary.getText().toString());
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(AccomplishmentsTableMetaData.CONTENT_URI, mAccId);
		contentResolver.update(uri, contentValues, null, null);
    }

    private void populateAccomplishment(long accId) {
    	Cursor cursor = managedQuery(AccomplishmentsTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				BaseColumns._ID + " = " + accId,
				null,
				null);

		cursor.moveToFirst();
		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());

		mAccName.setText(cursor.getString(cursor.getColumnIndex(AccomplishmentsTableMetaData.NAME)));
		mAccSummary.setText(cursor.getString(cursor.getColumnIndex(AccomplishmentsTableMetaData.SUMMARY)));
    }
}
