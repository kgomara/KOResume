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

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;

public class PackageActivity extends Activity {

	public static final String TAG	= "PackageActivity";
	private EditText mCoverLtr		= null;
	private static long mPackageId	= -1l;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.package_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get a reference to the Cover letter TextView
        mCoverLtr = (EditText) findViewById(R.id.packageCoverLtr);
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the packageId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mPackageId = extras.getLong("id");
        Log.v(TAG, "packageId = " + mPackageId);
        
        // Get the appropriate package from the database
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.PackageTableMetaData.CONTENT_URI,
				new String[] {PackageTableMetaData.COVER_LTR},
				PackageTableMetaData._ID + " = " + mPackageId,
				null,
				null);
    	if (cursor.getCount() > 0) {
    		// should have the package
    		cursor.moveToFirst();
    		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());
    		int colIdx = cursor.getColumnIndex(PackageTableMetaData.COVER_LTR);
    		String coverLtrText = cursor.getString(colIdx);
    		mCoverLtr.setText(coverLtrText);
    		cursor.close();
    	}
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.package_contents_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.packageAbout:
    		// TODO show the about intent
    		break;
    	case R.id.editCoverLtr:
    		// TODO make the EditText editable/not editable
//    		mCoverLtr.setFocusable(true); 
//    		mCoverLtr.setClickable(true);
    		break;
    	case R.id.saveCoverLtr:
    		// TODO make the EditText editable/not editable    		
//    		mCoverLtr.setFocusable(false); 
//    		mCoverLtr.setClickable(false);
    		String updatedCoverLtr = mCoverLtr.getText().toString();
    		updateCoverLtr(updatedCoverLtr);
    		break;
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    public void onResumeBtn(View view) {
    	// Launch the resumeActivity Intent
    	Intent intent = new Intent(this, ResumeActivity.class);
    	Bundle extras = new Bundle();
    	intent.putExtras(extras);
    	intent.putExtra("id", mPackageId);					// pass the row _Id of the selected package
    	this.startActivity(intent);
    	
    }
    
	private void updateCoverLtr(String coverLtr) {
		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.COVER_LTR, coverLtr);
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = ContentUris.withAppendedId(PackageTableMetaData.CONTENT_URI, mPackageId);
		contentResolver.update(uri, contentValues, null, null);
	}
}