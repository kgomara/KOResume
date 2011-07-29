package com.kevingomara.koresume;

import java.util.Calendar;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;

import com.kevingomara.koresume.KOResumeProviderMetaData.EducationTableMetaData;

public class EditEducationActivity extends Activity {

	private static final String TAG = "EditEducationActivity";
	private static long	 mResumeId	= 0;
	
	// references to the resume fields in the layout
	private EditText	mEduName	= null;
	private EditText	mEduTitle	= null;
	private TextView	mEduDate	= null;
    private Button 		mPickDate	= null;
    private int 		mYear		= 0;
    private int 		mMonth		= 0;
    private int 		mDay		= 0;

    static final int DATE_DIALOG_ID = 0;	

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.edit_education);
        
        Log.v(TAG, "onCreate() called");
        
        // Get the Resume Id passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mResumeId = extras.getLong("id");
        Log.v(TAG, "resumeId = " + mResumeId);
        
        // Get the ListView and register it for a context menu
        mEduName	= (EditText) findViewById(R.id.eduName);
        mEduTitle	= (EditText) findViewById(R.id.eduTitle);
        mEduDate	= (TextView) findViewById(R.id.eduEarnedDateLbl);
        mPickDate 	= (Button) 	 findViewById(R.id.eduEarnedDateBtn);

        // add a click listener to the button
        mPickDate.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showDialog(DATE_DIALOG_ID);
            }
        });

        // Populate the education
        populateEducation(mResumeId);
    }
    
    // the callback received when the user "sets" the date in the dialog
    private DatePickerDialog.OnDateSetListener mDateSetListener = new DatePickerDialog.OnDateSetListener() {

        public void onDateSet(DatePicker view, int year, 
                              int monthOfYear, int dayOfMonth) {
            mYear 	= year;
            mMonth 	= monthOfYear;
            mDay 	= dayOfMonth;
            updateDateDisplay();
        }
    };

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case DATE_DIALOG_ID:
        	Log.v(TAG, "year, month, day =" + mYear + ", " + mMonth + ", " + mDay);
            return new DatePickerDialog(this,
                        mDateSetListener,
                        mYear, mMonth, mDay);
        }
        return null;
    }

    // updates the date in the TextView
    private void updateDateDisplay() {
        mEduDate.setText(
            new StringBuilder()
                    // Month is 0 based so add 1
                    .append(mMonth + 1).append("-")
                    .append(mDay).append("-")
                    .append(mYear).append(" "));
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
     * Save the updated Education/Certification to the db
     * 
     * @param view
     */
    public void onSaveBtn(View view) {
    	saveEducation();
    	this.finish(); 
    }
    
    private void saveEducation() {
    	
		ContentValues contentValues = new ContentValues();
		contentValues.put(EducationTableMetaData.NAME,			mEduName.getText().toString());
		contentValues.put(EducationTableMetaData.TITLE,			mEduTitle.getText().toString());

		// Convert the date fields to a long
		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.DAY_OF_MONTH, mDay);
		calendar.set(Calendar.MONTH, mMonth);
		calendar.set(Calendar.YEAR, mYear);
		long eduDate = calendar.getTime().getTime();
		contentValues.put(EducationTableMetaData.EARNED_DATE, 	eduDate);
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(EducationTableMetaData.CONTENT_URI, mResumeId);
		contentResolver.update(uri, contentValues, null, null);
    }

    private void populateEducation(long eduId) {
    	Cursor cursor = managedQuery(EducationTableMetaData.CONTENT_URI,
				null,										// we want all the columns
				BaseColumns._ID + " = " + eduId,
				null,
				null);

		cursor.moveToFirst();
		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());

		mEduName.setText(cursor.getString(cursor.getColumnIndex(EducationTableMetaData.NAME)));
		mEduTitle.setText(cursor.getString(cursor.getColumnIndex(EducationTableMetaData.TITLE)));
		long eduDate = cursor.getLong(cursor.getColumnIndex(EducationTableMetaData.EARNED_DATE));
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(eduDate);
		mYear 	= cal.get(Calendar.YEAR);
		mMonth 	= cal.get(Calendar.MONTH);
		mDay	= cal.get(Calendar.DAY_OF_MONTH);
		
        // display the current date (this method is below)
        updateDateDisplay();
    }
}
