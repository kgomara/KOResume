package com.kevingomara.koresume;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.Dialog;
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
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;

import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;

public class JobActivity extends Activity {

	private static final String TAG 		= "jobActivity";
    private static final int START_DATE_ID 	= 0;	
    private static final int END_DATE_ID 	= 1;	
	
	private long 		mJobId			= 0l;
	
	// references to the fields in the layout
	private EditText 	mJobName	= null;
	private EditText 	mJobTitle 	= null;
	private EditText 	mCity		= null;
	private EditText 	mState		= null;
	private TextView 	mStartDate	= null;
	private TextView 	mEndDate	= null;
	private EditText	mSummary	= null;
	
	// fields to handle start and end dates
    private Button 		mPickStartDate	= null;
    private int 		mStartYear		= 0;
    private int 		mStartMonth		= 0;
    private int 		mStartDay		= 0;
    private long		mStartDateTime	= 0l;
    private Button 		mPickEndDate	= null;
    private int 		mEndYear		= 0;
    private int 		mEndMonth		= 0;
    private int 		mEndDay			= 0;
    private long		mEndDateTime	= 0l;

	
    public void onAccomplishmentsBtn(View view) {
    	// Launch the AccomplishmentsActivity Intent
    	Intent intent = new Intent(this, AccomplishmentsActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mJobId);					// pass the row _Id of the selected job
    	this.startActivity(intent);	
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.job_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get references to the job fields
        mJobName		= (EditText) findViewById(R.id.jobName);
        mSummary 		= (EditText) findViewById(R.id.jobSummary);
        mJobTitle		= (EditText) findViewById(R.id.jobTitle);
        mCity			= (EditText) findViewById(R.id.jobCity);
        mState			= (EditText) findViewById(R.id.jobState);
        mStartDate		= (TextView) findViewById(R.id.jobStartDate);
        mEndDate		= (TextView) findViewById(R.id.jobEndDate);
        mPickStartDate 	= (Button) 	 findViewById(R.id.pickStartDate);
        mPickEndDate 	= (Button) 	 findViewById(R.id.pickEndDate);        
        
        // add a click listener to the each button
        mPickStartDate.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showDialog(START_DATE_ID);
            }
        });
        mPickEndDate.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showDialog(END_DATE_ID);
            }
        });

        // Get the jobId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mJobId = extras.getLong("id");
        Log.v(TAG, "jobId = " + mJobId);
        
        // Get the appropriate job from the database
    	Cursor cursor = null;
    	cursor = getJob();
    	if (cursor.getCount() > 0) {
    		// should have the job
    		populateJobFields(cursor);
    	} else {
        	Log.e(TAG, "Error, no job found for Id = " + mJobId);
    	}
		cursor.close();
    }
    
    // the callback received when the user "sets" the date in the dialog
    private DatePickerDialog.OnDateSetListener mStartDateSetListener = new DatePickerDialog.OnDateSetListener() {

        public void onDateSet(DatePicker view, int year, 
                              int monthOfYear, int dayOfMonth) {
            mStartYear 	= year;
            mStartMonth = monthOfYear;
            mStartDay 	= dayOfMonth;
    		// Convert the date fields to a long
    		Calendar calendar = Calendar.getInstance();
    		calendar.set(Calendar.DAY_OF_MONTH, mStartDay);
    		calendar.set(Calendar.MONTH, mStartMonth);
    		calendar.set(Calendar.YEAR, mStartYear);
    		mStartDateTime = calendar.getTime().getTime();

            updateDateDisplay();
        }
    };

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case START_DATE_ID:
        	Log.v(TAG, "Start year, month, day =" + mStartYear + ", " + mStartMonth + ", " + mStartDay);
            return new DatePickerDialog(this,
                        mStartDateSetListener,
                        mStartYear, mStartMonth, mStartDay);
        case END_DATE_ID:
        	Log.v(TAG, "End year, month, day =" + mEndYear + ", " + mEndMonth + ", " + mEndDay);
            return new DatePickerDialog(this,
                        mEndDateSetListener,
                        mEndYear, mEndMonth, mEndDay);
        }
        return null;
    }

    // the callback received when the user "sets" the date in the dialog
    private DatePickerDialog.OnDateSetListener mEndDateSetListener = new DatePickerDialog.OnDateSetListener() {

        public void onDateSet(DatePicker view, int year, 
                              int monthOfYear, int dayOfMonth) {
            mEndYear 	= year;
            mEndMonth 	= monthOfYear;
            mEndDay 	= dayOfMonth;
            
    		// Convert the date fields to a long
    		Calendar calendar = Calendar.getInstance();
    		calendar.set(Calendar.DAY_OF_MONTH, mEndDay);
    		calendar.set(Calendar.MONTH, mEndMonth);
    		calendar.set(Calendar.YEAR, mEndYear);
    		mEndDateTime = calendar.getTime().getTime();
    		
            updateDateDisplay();
        }
    };

    // updates the date in the TextView
    private void updateDateDisplay() {
		// Set up Calendar and SimpleDateFormat objects for use
        Calendar cal = Calendar.getInstance();
        String format = "MMM yyyy";
        SimpleDateFormat sdf = new SimpleDateFormat(format);

        // Set the start date for the job display
        cal.setTimeInMillis(mStartDateTime);
        String dateString = sdf.format(cal.getTime());
        Log.v(TAG, "startDate = " + dateString);
		mStartDate.setText(dateString);
        
        // Set the start date for the job display
        cal.setTimeInMillis(mEndDateTime);
        dateString = sdf.format(cal.getTime());
        Log.v(TAG, "endDate = " + dateString);
		mEndDate.setText(dateString);
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
    	case R.id.viewAbout: {
        	// Launch the resumeActivity Intent
        	Intent intent = new Intent(this, AboutActivity.class);
        	this.startActivity(intent);
    		break;
    	}
    	case R.id.saveInfo: {
    		saveJob();
    		break;
    	}
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
        
    private Cursor getJob() {
    	Cursor cursor = managedQuery(JobsTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				BaseColumns._ID + " = " + mJobId,
				null,
				null);
    	
    	return cursor;
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
		mSummary.setText(cursor.getString(cursor.getColumnIndex(JobsTableMetaData.SUMMARY)));

        // Set the start date for the job display
        Calendar cal = Calendar.getInstance();
		mStartDateTime = cursor.getLong(cursor.getColumnIndex(JobsTableMetaData.START_DATE));
        cal.setTimeInMillis(mStartDateTime);
        
        // Set the start date fields for DatePicker usage
		mStartYear 	= cal.get(Calendar.YEAR);
		mStartMonth = cal.get(Calendar.MONTH);
		mStartDay	= cal.get(Calendar.DAY_OF_MONTH);
		
        // Set the end date for the job display
		mEndDateTime = cursor.getLong(cursor.getColumnIndex(JobsTableMetaData.END_DATE));
        cal.setTimeInMillis(mEndDateTime);
        
        // Set the start date fields for DatePicker usage
		mEndYear 	= cal.get(Calendar.YEAR);
		mEndMonth 	= cal.get(Calendar.MONTH);
		mEndDay		= cal.get(Calendar.DAY_OF_MONTH);

        // display the current date (this method is below)
        updateDateDisplay();
    }
    
    private boolean resumeFieldsAreValid() {
    	// check that all required fields contain data and are otherwise valid
    	if (TextUtils.isEmpty(mJobName.getText().toString())) {
    		showAlert(R.string.nameIsRequired, R.string.resumeNotSaved);
    		return false;
    	}
    	
    	return true;
    }
    
    private void saveJob() {
    	
    	if (!resumeFieldsAreValid()) {
    		return;
    	}
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(JobsTableMetaData.NAME,				mJobName.getText().toString());
		contentValues.put(JobsTableMetaData.SUMMARY,			mSummary.getText().toString());
		contentValues.put(JobsTableMetaData.CITY, 				mCity.getText().toString());
		contentValues.put(JobsTableMetaData.STATE,				mState.getText().toString());
		contentValues.put(JobsTableMetaData.TITLE,				mJobTitle.getText().toString());
		contentValues.put(JobsTableMetaData.START_DATE,			mStartDateTime);
		contentValues.put(JobsTableMetaData.END_DATE, 			mEndDateTime);
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(JobsTableMetaData.CONTENT_URI, mJobId);
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
