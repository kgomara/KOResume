package com.kevingomara.koresume;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class ResumeActivity extends Activity {

	private static final String TAG = "resumeActivity";
	
	private long 		mPackageId 		= 0l;
	private long 		mResumeId		= 0l;
	private EditText 	mResumeName		= null;
	private EditText 	mSummaryText 	= null;
	private EditText 	mStreet1		= null;
	private EditText 	mStreet2		= null;
	private EditText 	mCity			= null;
	private EditText 	mState			= null;
	private EditText 	mPostalCode		= null;
	private EditText 	mHomePhone		= null;
	private EditText 	mMobilePhone	= null;
	
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.resume_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get a reference to the Cover letter TextView
        mResumeName		= (EditText) findViewById(R.id.resumeName);
        mSummaryText	= (EditText) findViewById(R.id.resumeSummaryText);
        mStreet1		= (EditText) findViewById(R.id.resumeStreet1);
        mStreet2		= (EditText) findViewById(R.id.resumeStreet2);
        mCity			= (EditText) findViewById(R.id.resumeCity);
        mState			= (EditText) findViewById(R.id.resumeState);
        mPostalCode		= (EditText) findViewById(R.id.resumePostalCode);
        mHomePhone		= (EditText) findViewById(R.id.resumeHomePhone);
        mMobilePhone	= (EditText) findViewById(R.id.resumeMobilePhone);
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the packageId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mPackageId = extras.getLong("id");
        Log.v(TAG, "packageId = " + mPackageId);
        
        // Get the appropriate resume from the database
    	Cursor cursor = managedQuery(ResumeTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				ResumeTableMetaData.PACKAGE_ID + " = " + mPackageId,
				null,
				null);
    	if (cursor.getCount() > 0) {
    		// should have the resume
    		populateResumeFields(cursor);
    	}
		cursor.close();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.resume_contents_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.resumeAbout:
    		// TODO show the about intent
    		break;
    	case R.id.editSummaryInfo:
    		// TODO make the EditText editable/not editable
//    		mCoverLtr.setFocusable(true); 
//    		mCoverLtr.setClickable(true);
    		break;
    	case R.id.saveSummaryInfo:
    		// TODO make the EditText editable/not editable    		
//    		mCoverLtr.setFocusable(false); 
//    		mCoverLtr.setClickable(false);
    		saveResume();
    		break;
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    public void onJobsBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, JobsActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mResumeId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }
    
    public void onEducationBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, EducationActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mResumeId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }

    /*
     * helper methods
     */
    private void populateResumeFields(Cursor cursor) {
		cursor.moveToFirst();
		mResumeId = cursor.getLong(cursor.getColumnIndex(ResumeTableMetaData._ID));
		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());
		// TODO add the other fields
		mResumeName.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.RESUME_NAME)));
		mSummaryText.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.SUMMARY_TEXT)));
		mStreet1.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STREET1)));
		mStreet2.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STREET2)));
		mCity.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.CITY)));
		mState.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STATE)));
		mPostalCode.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.POSTAL_CODE)));
		mHomePhone.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.HOME_PHONE)));
		mMobilePhone.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.MOBILE_PHONE)));
    }
    
    private void saveResume() {
    	
    	if (!resumeFieldsAreValid()) {
    		return;
    	}
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(ResumeTableMetaData.RESUME_NAME,		mResumeName.getText().toString());
		contentValues.put(ResumeTableMetaData.SUMMARY_TEXT,		mSummaryText.getText().toString());
		contentValues.put(ResumeTableMetaData.STREET1, 			mStreet1.getText().toString());
		contentValues.put(ResumeTableMetaData.STREET2, 			mStreet2.getText().toString());
		contentValues.put(ResumeTableMetaData.CITY, 			mCity.getText().toString());
		contentValues.put(ResumeTableMetaData.STATE,			mState.getText().toString());
		contentValues.put(ResumeTableMetaData.POSTAL_CODE,		mPostalCode.getText().toString());
		contentValues.put(ResumeTableMetaData.HOME_PHONE,		mHomePhone.getText().toString());
		contentValues.put(ResumeTableMetaData.MOBILE_PHONE, 	mMobilePhone.getText().toString());
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(ResumeTableMetaData.CONTENT_URI, mResumeId);
		contentResolver.update(uri, contentValues, null, null);

    }
    
    private boolean resumeFieldsAreValid() {
    	
    	return true;
    }
}
