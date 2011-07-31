package com.kevingomara.koresume;

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
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.EducationTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class MainActivity extends Activity /* implements OnItemClickListener */ {
	
	private static final String TAG 		= "MainActivity";
	private static final int DELETE_ITEM 	= 998;
	private static final int CANCEL_ITEM	= 999;
	
	private Context mContext				= this;
	private boolean isFirstTry				= true;
	private long mPackageId					= 0l;
	
	private ListView mListView 				= null;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        // Get the ListView
        mListView = (ListView) findViewById(R.id.listView);
        registerForContextMenu(mListView);

        // Populate the list of packages
        populatePackages();
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.main_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.about: {
        	// Launch the resumeActivity Intent
        	Intent intent = new Intent(this, AboutActivity.class);
        	this.startActivity(intent);
    		break;
    	}
    	case R.id.addPackage: {
    		addPackage();
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
        mPackageId = info.id;
    	menu.add(Menu.NONE, DELETE_ITEM, Menu.NONE, R.string.deletePackage);
    	menu.add(Menu.NONE, CANCEL_ITEM, Menu.NONE, R.string.cancel);
    }
    
    @Override
    public boolean onContextItemSelected(MenuItem menuItem) {
    	
    	int itemId = menuItem.getItemId();
    	switch (itemId) {
	    	case DELETE_ITEM: {
	    		deletePackageOnConfirm();
	    		break;
	    	}
	    	case CANCEL_ITEM: {
	    		// User canceled - do nothing
	    		break;
	    	}
    	}
    	
    	return true;
    }
    
    private void deletePackageOnConfirm() {
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
    	builder.setTitle(getString(R.string.areYouSure));
    	builder.setMessage(getString(R.string.packageEverythingWillGo));
        builder.setCancelable(true);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
			public void onClick(DialogInterface dialog, int id) {
                 deleteEntirePackageContents();
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
     * Delete the package and all related database items
     * 
     * Get the resumeId, then its Jobs.  For each Job, delete all its Accomplishments, then the Job.
     * 		Delete all the Education/Certifications associated with the Resume, then the Resume.
     * 		Finally, delete the Package itself.
     * 
     * @return
     */
    private void deleteEntirePackageContents() {
    	// First get the resumeId associated with the Package the User long-clicked
    	long resumeId = getResumeIdFromPackage(mPackageId);
    	Log.v(TAG, "resumeId = " + resumeId);
    	
    	if (resumeId > 0l) {
    		// Drill down another level
    		deleteEducationFromResume(resumeId);
    		// Delete the Jobs and their Accomplishments
    		deleteJobsAndAccomplishmentsFromResume(resumeId);
    		// Delete the Resume
    		deleteResume(resumeId);
    	}

    	// Finally, delete the Package
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = PackageTableMetaData.CONTENT_URI;
    	Uri deleteUri = Uri.withAppendedPath(uri, Integer.toString((int) mPackageId));
    	Log.v(TAG, "packageUri = " + deleteUri);
     	contentResolver.delete(deleteUri, null, null);
    }
    
    private long getResumeIdFromPackage(long packageId) {
    	// Set up to get the selected package
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = PackageTableMetaData.CONTENT_URI;
    	Uri queryUri = Uri.withAppendedPath(uri, Integer.toString((int) packageId));
    	Log.v(TAG, "packageUri = " + queryUri);
    	Cursor cursor = contentResolver.query(queryUri, null, null, null, null);
    	
    	// Cursor should be = 1
    	if (cursor.getCount() > 0) {
    		// should have the package
    		cursor.moveToFirst();
    		Log.v(TAG, "cursor.getCount() = " + cursor.getCount());
    		int colIdx = cursor.getColumnIndex(PackageTableMetaData.RESUME_ID);
    		return cursor.getLong(colIdx);
    	}
    	// opps!
    	return 0l;
    }
    
    private void deleteEducationFromResume(long resumeId) {
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = EducationTableMetaData.CONTENT_URI;
    	String where = EducationTableMetaData.RESUME_ID + " = ?";
    	String[] whereArgs = {Integer.toString((int) resumeId)};
    	Log.v(TAG, "Education uri = " + uri + " " + where);
     	contentResolver.delete(uri, where, whereArgs);
    }
    
    private void deleteJobsAndAccomplishmentsFromResume(long resumeId) {
    	// Query the database for all the Jobs associated with this Resume
       	Cursor cursor = managedQuery(JobsTableMetaData.CONTENT_URI,
				null,
				JobsTableMetaData.RESUME_ID + " = " + resumeId,
				null,
				null);
       	int colIdx = cursor.getColumnIndex(JobsTableMetaData._ID);
	    ContentResolver contentResolver = this.getContentResolver();
	    Uri uri = AccomplishmentsTableMetaData.CONTENT_URI;
   	   	String where = AccomplishmentsTableMetaData.JOBS_ID + " = ?";
       	if (cursor.moveToFirst()) {
       		do {
       			// Got a Job, Delete its Accomplishments
       			String jobId = cursor.getString(colIdx);
       	    	String[] whereArgs = {jobId};
       	    	Log.v(TAG, "Accomplishments uri = " + uri + " " + where);
       	     	contentResolver.delete(uri, where, whereArgs);
       		} while (cursor.moveToNext());
       	}
    	// All the Accomplishments for all the Jobs have been deleted.  Delete the Jobs
       	uri = JobsTableMetaData.CONTENT_URI;
       	where = JobsTableMetaData.RESUME_ID + " = ?";
       	String[] whereArgs = {Integer.toString((int) resumeId)};
	    Log.v(TAG, "Jobss uri = " + uri + " " + where);
   	    contentResolver.delete(uri, where, whereArgs);       	
    }
    
    private void deleteResume(long resumeId) {
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = ResumeTableMetaData.CONTENT_URI;
    	Uri deleteUri = Uri.withAppendedPath(uri, Integer.toString((int) resumeId));
    	Log.v(TAG, "resumeUri = " + deleteUri);
    	contentResolver.delete(deleteUri, null, null);
    }
    
    private void addPackage() {
				
		AlertDialog.Builder alert = new AlertDialog.Builder(this);

		alert.setTitle(R.string.promptTitle);
		alert.setMessage(R.string.promptPackageText);

		// Set an EditText view to get user input 
		final EditText input = new EditText(this);
		alert.setView(input);

		alert.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int whichButton) {
				String packageName = input.getText().toString();
				Log.v(TAG, "packageName = " + packageName);
				insertPackage(packageName);
			  	}
			});

		alert.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int whichButton) {
			    // Canceled.
				}
			});

		alert.show();		
	}
    	
	private void insertPackage(String name) {
		ContentValues cv = new ContentValues();
		cv.put(KOResumeProviderMetaData.PackageTableMetaData.NAME, name);
		cv.put(KOResumeProviderMetaData.PackageTableMetaData.RESUME_ID, 0);
	
		ContentResolver cr = this.getContentResolver();
		Uri uri = KOResumeProviderMetaData.PackageTableMetaData.CONTENT_URI;
		Log.d(TAG, "insertPackage uri: " + uri);
		Uri insertedUri = cr.insert(uri, cv);
		Log.d(TAG, "inserted uri: " + insertedUri);
	}
	
	private void populatePackages() {
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.PackageTableMetaData.CONTENT_URI,
    						null,
    						null,
    						null,
    						null);
    	if (cursor.getCount() > 0) {
    		String[] 	cols 	= new String[] {PackageTableMetaData.NAME};
    		int[] 		views	= new int[] {android.R.id.text1};
    		SimpleCursorAdapter adapter = new SimpleCursorAdapter(this,
    										R.layout.list_black_text,
    										cursor, 
    										cols,
    										views);
    		mListView.setAdapter(adapter);
    		mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    			@Override
    		    public void onItemClick(AdapterView<?> adapter, View view, int position, long id) {
    		    	// Launch the packageActivity Intent
    		    	Intent intent = new Intent(mContext, PackageActivity.class);
    		    	Bundle extras = new Bundle();
    		    	intent.putExtras(extras);
    		    	intent.putExtra("id", id);					// pass the row _Id of the selected package
    		    	mContext.startActivity(intent);
    		    }
    		});
    	} else if (isFirstTry) {
    		isFirstTry = false;
			TestData testData = new TestData(mContext);
			testData.create();
			populatePackages();
    	}
    }
}