package com.kevingomara.koresume;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.SimpleCursorAdapter;
import android.widget.TextView;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;

public class JobActivity extends Activity {

	private static final String TAG = "jobActivity";
	
	private long 		mJobId		= 0l;
	private long		mResumeId	= 0l;
	
	// references to the resume fields in the layout
	private EditText 	mJobName	= null;
	private EditText 	mJobTitle 	= null;
	private EditText 	mCity		= null;
	private EditText 	mState		= null;
	private TextView 	mStartDate	= null;
	private TextView 	mEndDate	= null;
	private EditText	mSummary	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.job_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get references to the resume fields


        mJobName	= (EditText) findViewById(R.id.jobName);
        mSummary 	= (EditText) findViewById(R.id.jobSummary);
        mJobTitle	= (EditText) findViewById(R.id.jobTitle);
        mCity		= (EditText) findViewById(R.id.jobCity);
        mState		= (EditText) findViewById(R.id.jobState);
        mStartDate	= (TextView) findViewById(R.id.jobStartDate);
        mEndDate	= (TextView) findViewById(R.id.jobEndDate);
        
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the packageId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mJobId = extras.getLong("id");
        Log.v(TAG, "jobId = " + mJobId);
        
        // Get the appropriate resume from the database
    	Cursor cursor = null;
    	cursor = getJob();
    	if (cursor.getCount() > 0) {
    		// should have the job
    		populateJobFields(cursor);
    	} else {
        	Log.e(TAG, "Error, could not create Resume");
    	}
		cursor.close();
		
//		populateAccomplishments(mJobId);
    }
    
    private Cursor getJob() {
    	Cursor cursor = managedQuery(JobsTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				JobsTableMetaData._ID + " = " + mJobId,
				null,
				null);
    	
    	return cursor;
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.default_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.viewAbout:
    		// TODO show the about intent
    		break;
    	case R.id.editInfo:
    		// TODO make the EditText editable/not editable
//    		mCoverLtr.setFocusable(true); 
//    		mCoverLtr.setClickable(true);
    		break;
    	case R.id.saveInfo:
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
    
    public void onStartDateBtn(View view) {
    	// Set the Start Date    	
    }
    
    public void onEndDateBtn(View view) {
    	// Set the End Date
    }
    
    public void onAccomplishmentsBtn(View view) {
    	
    }

    /*
     * helper methods
     */
    private void populateJobFields(Cursor cursor) {
		cursor.moveToFirst();
		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());

		mJobName.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.NAME)));
		mJobTitle.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.TITLE)));
		mCity.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.CITY)));
		mState.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.STATE)));
		mStartDate.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.START_DATE)));
		mEndDate.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.END_DATE)));
		mSummary.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.SUMMARY)));
    }
    
    private void saveResume() {
    	
    	if (!resumeFieldsAreValid()) {
    		return;
    	}
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(JobsTableMetaData.NAME,				mJobName.getText().toString());
		contentValues.put(JobsTableMetaData.SUMMARY,			mSummary.getText().toString());
		contentValues.put(JobsTableMetaData.CITY, 				mCity.getText().toString());
		contentValues.put(JobsTableMetaData.STATE,				mState.getText().toString());
		contentValues.put(JobsTableMetaData.TITLE,				mJobTitle.getText().toString());
		contentValues.put(JobsTableMetaData.START_DATE,			mStartDate.getText().toString());
		contentValues.put(JobsTableMetaData.END_DATE, 			mEndDate.getText().toString());
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(JobsTableMetaData.CONTENT_URI, mJobId);
		contentResolver.update(uri, contentValues, null, null);

    }
/*    
    private void populateAccomplishments(long jobId) {
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.AccomplishmentsTableMetaData.CONTENT_URI,
    						null,
    						KOResumeProviderMetaData.AccomplishmentsTableMetaData.JOBS_ID + " = " + jobId,
    						null,
    						null);
    	if (cursor.getCount() > 0) {
    		String[] 	cols 	= new String[] {AccomplishmentsTableMetaData.NAME, AccomplishmentsTableMetaData.SUMMARY};
    		int[] 		views	= new int[] {R.id.twoLineText1, R.id.twoLineText2};
    		SimpleCursorAdapter adapter = new SimpleCursorAdapter(this,
    										R.layout.layout_two_line_list_cell,
    										cursor, 
    										cols,
    										views);
    		mListView.setAdapter(adapter);
    		mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    			@Override
    		    public void onItemClick(AdapterView<?> adapter, View view, int position, long id) {
    		    	// Launch the packageActivity Intent
    		    }
    		});
    	} 
    }

	private void insertAccomplishment(String name) {
		ContentValues cv = new ContentValues();
		cv.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.NAME, name);
		cv.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.JOBS_ID, mJobId);
	
		ContentResolver cr = this.getContentResolver();
		Uri uri = KOResumeProviderMetaData.AccomplishmentsTableMetaData.CONTENT_URI;
		Log.d(TAG, "insertAccomplishment uri: " + uri);
		Uri insertedUri = cr.insert(uri, cv);
		Log.d(TAG, "inserted uri: " + insertedUri);
}
*/
    
    private boolean resumeFieldsAreValid() {
    	// check that all required fields contain data and are otherwise valid
    	if (TextUtils.isEmpty(mJobName.getText().toString())) {
    		showAlert(R.string.nameIsRequired, R.string.resumeNotSaved);
    		return false;
    	}
    	
    	return true;
    }
    
    private void showAlert(int titleString, int messageString) {
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
    	builder.setTitle(titleString);
    	builder.setMessage(messageString);
        builder.setCancelable(false);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
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
