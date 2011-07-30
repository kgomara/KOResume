package com.kevingomara.koresume;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class ResumeActivity extends Activity {

	private static final String TAG 		= "resumeActivity";
	private static final int DELETE_RESUME 	= 999;
	
	private long 		mPackageId 		= 0l;
	private long 		mResumeId		= 0l;
	
	// references to the resume fields in the layout
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
        
        // Get references to the resume fields
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
    	Cursor cursor = null;
    	cursor = getResume();
    	if (cursor.getCount() > 0) {
    		// should have the resume
    		populateResumeFields(cursor);
    	} else {
    		insertResume(this.getString(R.string.resumeDefaultName));
    		cursor = getResume();
        	if (cursor.getCount() > 0) {
        		// should have the resume
        		populateResumeFields(cursor);
        	} else {
        		Log.e(TAG, "Error, could not create Resume");
        	}
    	}
		cursor.close();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.default_menu, menu);
        MenuItem menuItem = menu.add(Menu.NONE, DELETE_RESUME, Menu.NONE, R.string.deleteResume);
        menuItem.setIcon(R.drawable.ic_menu_delete);
        
        return true;
    }
    
    public void onEducationBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, EducationActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mResumeId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }
    
    public void onJobsBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, JobsActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mResumeId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.viewAbout: {
        	// Launch the resumeActivity Intent
        	Intent intent = new Intent(this, AboutActivity.class);
        	this.startActivity(intent);
    		break;
    	}
    	case R.id.editInfo: {
    		// TODO make the EditText editable/not editable
//    		mCoverLtr.setFocusable(true); 
//    		mCoverLtr.setClickable(true);
    		break;
    	}
    	case R.id.saveInfo: {
    		// TODO make the EditText editable/not editable    		
//    		mCoverLtr.setFocusable(false); 
//    		mCoverLtr.setClickable(false);
    		saveResume();
    		break;
    	}
    	case DELETE_RESUME: {
    		deleteResume();
    		break;
    	}
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    private void deleteResume() {
    	// TODO implement
    }
    
    private Cursor getResume() {
    	Cursor cursor = managedQuery(ResumeTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				ResumeTableMetaData.PACKAGE_ID + " = " + mPackageId,
				null,
				null);
    	
    	return cursor;
    }

    private void insertResume(String name) {
		ContentValues cv = new ContentValues();
		cv.put(KOResumeProviderMetaData.ResumeTableMetaData.NAME, name);
		cv.put(KOResumeProviderMetaData.ResumeTableMetaData.PACKAGE_ID, mPackageId);
	
		ContentResolver cr = this.getContentResolver();
		Uri uri = KOResumeProviderMetaData.ResumeTableMetaData.CONTENT_URI;
		Log.d(TAG, "insertPackage uri: " + uri);
		Uri insertedUri = cr.insert(uri, cv);
		Log.d(TAG, "inserted uri: " + insertedUri);
		
		// Update the Package with the newly created resume _ID
		long resumeId = Integer.parseInt(insertedUri.getPathSegments().get(1));
		Uri insertedPackageUri = ContentUris.withAppendedId( PackageTableMetaData.CONTENT_URI, mPackageId);

		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.RESUME_ID, resumeId);

		ContentResolver cr2 = this.getContentResolver();
		Log.d(TAG, "updatePackage uri: " + insertedPackageUri);
		cr2.update(insertedPackageUri, contentValues, null, null);

	}
    
    /*
     * helper methods
     */
    private void populateResumeFields(Cursor cursor) {
		cursor.moveToFirst();
		mResumeId = cursor.getLong(cursor.getColumnIndex(BaseColumns._ID));
		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());

		mResumeName.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.NAME)));
		mSummaryText.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.SUMMARY)));
		mStreet1.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STREET1)));
		mStreet2.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STREET2)));
		mCity.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.CITY)));
		mState.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.STATE)));
		mPostalCode.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.POSTAL_CODE)));
		mHomePhone.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.HOME_PHONE)));
		mMobilePhone.setText(cursor.getString(cursor.getColumnIndex(ResumeTableMetaData.MOBILE_PHONE)));
    }
    
	private boolean resumeFieldsAreValid() {
    	// check that all required fields contain data and are otherwise valid
    	if (TextUtils.isEmpty(mResumeName.getText().toString())) {
    		showAlert(R.string.nameIsRequired, R.string.resumeNotSaved);
    		return false;
    	}
    	
    	return true;
    }

    
    private void saveResume() {
    	
    	if (!resumeFieldsAreValid()) {
    		return;
    	}
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(ResumeTableMetaData.NAME,				mResumeName.getText().toString());
		contentValues.put(ResumeTableMetaData.SUMMARY,			mSummaryText.getText().toString());
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
    
    private void showAlert(int titleString, int messageString) {
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
    	builder.setTitle(titleString);
    	builder.setMessage(messageString);
        builder.setCancelable(false);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
			public void onClick(DialogInterface dialog, int id) {
                 // Nothing to do?
            }
        });
/*        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                 dialog.cancel();
            }
        }); */
        AlertDialog alert = builder.create();
    	alert.show();
    }
}
