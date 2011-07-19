package com.kevingomara.koresume;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
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
	
	private long mPackageId = 0l;
	private EditText mSummary = null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.resume_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get a reference to the Cover letter TextView
        mSummary = (EditText) findViewById(R.id.resumeSummaryText);
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the packageId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mPackageId = extras.getLong("id");
        Log.v(TAG, "packageId = " + mPackageId);
        
        // Get the appropriate resume from the database
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.ResumeTableMetaData.CONTENT_URI,
				new String[] {ResumeTableMetaData.SUMMARY_TEXT},
				ResumeTableMetaData.PACKAGE_ID + " = " + mPackageId,
				null,
				null);
    	if (cursor.getCount() > 0) {
    		// should have the package
    		cursor.moveToFirst();
    		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());
    		// TODO add the other fields
    		int colIdx = cursor.getColumnIndex(ResumeTableMetaData.SUMMARY_TEXT);
    		String summaryText = cursor.getString(colIdx);
    		mSummary.setText(summaryText);
    		cursor.close();
    	}
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
    		// TODO get the other fields
    		String updatedSummary = mSummary.getText().toString();
//    		updateCoverLtr(updatedCoverLtr);
    		break;
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    public void onJobsBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, ResumeActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mPackageId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }
    
    public void onEducationBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, ResumeActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mPackageId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }


}
