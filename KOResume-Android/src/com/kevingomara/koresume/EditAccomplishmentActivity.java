package com.kevingomara.koresume;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.EditText;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;

public class EditAccomplishmentActivity extends Activity {

	private static final String TAG = "AccomplishmentsActivity";
	private static long	mAccId		= 0;
	
	// references to the resume fields in the layout
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
        Log.v(TAG, "jobId = " + mAccId);
        
        // Get the ListView and register it for a context menu
        mAccName	= (EditText) findViewById(R.id.accName);
        mAccSummary	= (EditText) findViewById(R.id.accSummary);
        
        // Populate the list of accomplishments
        populateAccomplishment(mAccId);
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
    		saveAccomplishment();
    		break;
    	}
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    private void saveAccomplishment() {
    	
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
