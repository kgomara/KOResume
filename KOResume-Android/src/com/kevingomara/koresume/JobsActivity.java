package com.kevingomara.koresume;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;

public class JobsActivity extends Activity {

	private static final String TAG = "JobsActivity";
	
	private Context		mContext	= this;
	private long		mResumeId	= 0;
	private ListView	mListView	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.jobs_layout);
        
        Log.v(TAG, "onCreate() called");

        // Get the packageId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mResumeId = extras.getLong("id");
        Log.v(TAG, "resumeId = " + mResumeId);
        
        // Get the ListView
        mListView = (ListView) findViewById(R.id.jobsListView);

        // Populate the list of jobs
        populateJobs();        
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
    		saveJobs();
    		break;
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    private void populateJobs() {
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.JobsTableMetaData.CONTENT_URI,
    						null,
    						KOResumeProviderMetaData.JobsTableMetaData.RESUME_ID + " = " + mResumeId,
    						null,
    						null);
    	if (cursor.getCount() > 0) {
    		String[] 	cols 	= new String[] {JobsTableMetaData.NAME, JobsTableMetaData.TITLE};
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
    		    	Intent intent = new Intent(mContext, JobActivity.class);
    		    	Bundle extras = new Bundle();
    		    	intent.putExtras(extras);
    		    	intent.putExtra("id", id);					// pass the row _Id of the selected package
    		    	mContext.startActivity(intent);
    		    }
    		});
    	}
    }
    
    private void saveJobs() {
    	
    }
    
}
