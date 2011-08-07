package com.kevingomara.koresume;

import java.util.Calendar;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;

public class JobsActivity extends Activity {

	private static final String TAG 		= "JobsActivity";
	private static final int	ADD_JOB		= 997;
	private static final int	DELETE_ITEM	= 999;
	
	private Context		mContext	= this;
	private long		mResumeId	= 0;
	private ListView	mListView	= null;
	private long		mJobId		= 0l;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.jobs_layout);
        
        Log.v(TAG, "onCreate() called");

        // Get the resumeId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mResumeId = extras.getLong("id");
        Log.v(TAG, "resumeId = " + mResumeId);
        
        // Get the ListView
        mListView = (ListView) findViewById(R.id.jobsListView);
        registerForContextMenu(mListView);

        // Populate the list of jobs
        populateJobs();        
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	
    	// Hack to force reload of jobs data after intial add
    	populateJobs();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.default_menu, menu);
        MenuItem menuItem = menu.add(Menu.NONE, ADD_JOB, Menu.NONE, R.string.addJob);
        menu.removeItem(R.id.saveInfo);
        menuItem.setIcon(R.drawable.ic_menu_add);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.viewAbout: {
        	// Launch the aboutActivity Intent
        	Intent intent = new Intent(this, AboutActivity.class);
        	this.startActivity(intent);
    		break;
    	}
    	case ADD_JOB: {
    		long newJobId = insertJob();
	    	Intent intent = new Intent(mContext, JobActivity.class);
	    	Bundle extras = new Bundle();
	    	intent.putExtras(extras);
	    	intent.putExtra("id", newJobId);				// pass the row _Id of the selected job
	    	mContext.startActivity(intent);
    		break;
    	}
    	default:
    		Log.e(TAG, "Error, unknown menuItem: " + menuItem.getItemId());	
    	}
    	
    	return true;
    }
    
    @Override
    public void onCreateContextMenu(ContextMenu menu, View view, ContextMenuInfo menuInfo) {
        AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo) menuInfo;
        mJobId = info.id;
    	menu.add(Menu.NONE, DELETE_ITEM, Menu.NONE, R.string.deleteJob);
    }
    
    @Override
    public boolean onContextItemSelected(MenuItem menuItem) {
    	
    	int itemId = menuItem.getItemId();
    	switch (itemId) {
	    	case DELETE_ITEM: {
	    		deleteJobOnConfirm();
	    		break;
	    	}
    	}
    	
    	return true;
    }
    
    private void deleteJobOnConfirm() {
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
    	builder.setTitle(getString(R.string.areYouSure));
    	builder.setMessage(getString(R.string.jobEverythingWillGo));
        builder.setCancelable(true);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
			public void onClick(DialogInterface dialog, int id) {
                 deleteJobAndAccomplishments();
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                 dialog.cancel();
            }
        });
        AlertDialog alert = builder.create();
    	alert.show();
    }
    
    /**
     * Delete the job and all related Accomplishments
     * 
     * @return
     */
    private void deleteJobAndAccomplishments() {
    	// First delete all the Accomplishments associated with this job
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = AccomplishmentsTableMetaData.CONTENT_URI;
    	String where = AccomplishmentsTableMetaData.JOBS_ID + " = ?";
    	String[] whereArgs = {Integer.toString((int) mJobId)};
    	Log.v(TAG, "Accomplishments uri = " + uri + " " + where);
     	contentResolver.delete(uri, where, whereArgs);
     	
     	// There may be no Accomplishments to delete, so we assume all went OK
     	// 		...so go ahead and delete the job
     	uri = JobsTableMetaData.CONTENT_URI;
    	Uri delUri = Uri.withAppendedPath(uri, Integer.toString((int) mJobId));
    	Log.d(TAG, "delUri = " + delUri);
     	contentResolver.delete(delUri, null, null);
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
    		    	// Launch the jobActivity Intent
    		    	Intent intent = new Intent(mContext, JobActivity.class);
    		    	Bundle extras = new Bundle();
    		    	intent.putExtras(extras);
    		    	intent.putExtra("id", id);					// pass the row _Id of the selected job
    		    	mContext.startActivity(intent);
    		    }
    		});
    	}
    }
    
    private long insertJob() {
		ContentValues contentValues = new ContentValues();
//		contentValues.put(JobsTableMetaData.NAME,		getString(R.string.defaultJobName));
		contentValues.put(JobsTableMetaData.RESUME_ID,	mResumeId);

		// Convert the date fields to a long
		Calendar calendar = Calendar.getInstance();				// Calendar date defaults to now
		long defaultDate  = calendar.getTime().getTime();
		contentValues.put(JobsTableMetaData.START_DATE,	defaultDate);
		contentValues.put(JobsTableMetaData.END_DATE, 	defaultDate);
	
		ContentResolver contentResolver = this.getContentResolver();
		Uri uri = JobsTableMetaData.CONTENT_URI;
		Uri insertedUri = contentResolver.insert(uri, contentValues);
		
		return Integer.parseInt(insertedUri.getPathSegments().get(1));    	
    }    
}
