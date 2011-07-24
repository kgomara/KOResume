package com.kevingomara.koresume;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;

public class AccomplishmentsActivity extends Activity {

	private static final String TAG = "AccomplishmentsActivity";
	
	private long 		mJobId		= 0l;
	
	// references to the resume fields in the layout
	private ListView	mListView	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.accomplishments_layout);
        
        Log.v(TAG, "onCreate() called");
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the jobId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mJobId = extras.getLong("id");
        Log.v(TAG, "jobId = " + mJobId);
        
        // Get the ListView
        mListView	= (ListView) findViewById(R.id.accomplishmentsListView);
        
        // Populate the list of accomplishments
        populateAccomplishments(mJobId);
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
//    		saveAccomplishments();
    		break;
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    /*
     * helper methods
     */    
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
