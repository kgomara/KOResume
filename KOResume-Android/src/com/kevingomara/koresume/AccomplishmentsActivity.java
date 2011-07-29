package com.kevingomara.koresume;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
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
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;

public class AccomplishmentsActivity extends Activity {

	private static final String TAG 		= "AccomplishmentsActivity";
	private static final int	EDIT_ITEM	= 998;
	private static final int	DELETE_ITEM	= 999;
	
	private long 		mJobId		= 0l;
	private long		mAccId		= 0l;
	
	// references to the Accomplishments fields in the layout
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
        
        // Get the ListView and register it for a context menu
        mListView	= (ListView) findViewById(R.id.accomplishmentsListView);
        registerForContextMenu(mListView);
        
        // Populate the list of accomplishments
        populateAccomplishments(mJobId);
    }
    
    @Override
    public void onCreateContextMenu(ContextMenu menu, View view, ContextMenuInfo menuInfo) {
        AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo) menuInfo;
        mAccId = info.id;
    	menu.add(Menu.NONE, EDIT_ITEM, 	 Menu.NONE, R.string.editAccomplishment);
    	menu.add(Menu.NONE, DELETE_ITEM, Menu.NONE, R.string.deleteAccomplishment);
    }
    
    @Override
    public boolean onContextItemSelected(MenuItem menuItem) {
    	
    	int itemId = menuItem.getItemId();
    	switch (itemId) {
	    	case EDIT_ITEM: {
	        	// Launch the EditAccomplishmentsActivity Intent
	        	Intent intent = new Intent(this, EditAccomplishmentActivity.class);
	        	Bundle extras = new Bundle();
	        	intent.putExtras(extras);
	        	intent.putExtra("id", mAccId);					// pass the row _Id of the selected job
	        	this.startActivity(intent);	
	    		break;
	    	}
	    	case DELETE_ITEM: {
	    		deleteAccomplishment(mAccId);
	    		break;
	    	}
    	}
    	
    	return true;
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.add_info_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
    	switch (menuItem.getItemId()) {
    	case R.id.addViewAbout: {
        	// Launch the resumeActivity Intent
        	Intent intent = new Intent(this, AboutActivity.class);
        	this.startActivity(intent);
    		break;
    	}
    	case R.id.addInfo: {
        	// Launch the SaveAccomplishmentsActivity Intent
        	Intent intent = new Intent(this, SaveAccomplishmentActivity.class);
        	Bundle extras = new Bundle();
        	intent.putExtras(extras);
        	intent.putExtra("id", mJobId);					// pass the _Id of the selected job
        	this.startActivity(intent);	
    		break;
    	}
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
    
    private void deleteAccomplishment(long itemId) {
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = KOResumeProviderMetaData.AccomplishmentsTableMetaData.CONTENT_URI;
    	Uri delUri = Uri.withAppendedPath(uri, Integer.toString((int) itemId));
    	Log.d(TAG, "delUri = " + delUri);
    	contentResolver.delete(delUri, null, null);
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
