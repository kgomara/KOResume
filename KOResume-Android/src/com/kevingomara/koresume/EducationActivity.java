package com.kevingomara.koresume;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.kevingomara.koresume.KOResumeProviderMetaData.EducationTableMetaData;

public class EducationActivity extends Activity {

	private static final String TAG 		= "EducationActivity";
	private static final int	EDIT_ITEM	= 998;
	private static final int	DELETE_ITEM	= 999;
	
	private long 		mResumeId	= 0l;
	private long		mEduId		= 0l;
	
	// references to the fields in the layout
	private ListView	mListView	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.education_layout);
        
        Log.v(TAG, "onCreate() called");
        
        // Get the resumeId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mResumeId = extras.getLong("id");
        Log.v(TAG, "resumeId = " + mResumeId);
        
        // Get the ListView
        mListView	= (ListView) findViewById(R.id.educationListView);
        registerForContextMenu(mListView);
        
        // Populate the list of accomplishments
        populateEducation(mResumeId);
    }
    
    @Override
    public void onCreateContextMenu(ContextMenu menu, View view, ContextMenuInfo menuInfo) {
        AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo) menuInfo;
        mEduId = info.id;
    	menu.add(Menu.NONE, EDIT_ITEM, 	 Menu.NONE, R.string.editEducation);
    	menu.add(Menu.NONE, DELETE_ITEM, Menu.NONE, R.string.deleteEducation);
    }
    
    @Override
    public boolean onContextItemSelected(MenuItem menuItem) {
    	
    	int itemId = menuItem.getItemId();
    	switch (itemId) {
	    	case EDIT_ITEM: {
	        	// Launch the EditAccomplishmentsActivity Intent
	        	Intent intent = new Intent(this, EditEducationActivity.class);
	        	Bundle extras = new Bundle();
	        	intent.putExtras(extras);
	        	intent.putExtra("id", mEduId);					// pass the row _Id of the selected job
	        	this.startActivity(intent);	
	    		break;
	    	}
	    	case DELETE_ITEM: {
	    		deleteEducation(mEduId);
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
        	Intent intent = new Intent(this, SaveEducationActivity.class);
        	Bundle extras = new Bundle();
        	intent.putExtras(extras);
        	intent.putExtra("id", mResumeId);					// pass the _Id of the resume
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
    private void populateEducation(long jobId) {
    	Cursor cursor = managedQuery(KOResumeProviderMetaData.EducationTableMetaData.CONTENT_URI,
    						null,
    						KOResumeProviderMetaData.EducationTableMetaData.RESUME_ID + " = " + jobId,
    						null,
    						null);
    	if (cursor.getCount() > 0) {
     		mListView.setAdapter(new EduAdapter(this, cursor));
    		mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    			@Override
    		    public void onItemClick(AdapterView<?> adapter, View view, int position, long id) {
    		    	// Nothing needed here
    		    }
    		});
    	}
    }
    
    public class EduAdapter extends CursorAdapter {
        private final LayoutInflater mInflater;

        public EduAdapter(Context context, Cursor cursor) {
            super(context, cursor, false);
            mInflater = LayoutInflater.from(context);
        }

        @Override
        public View newView(Context context, Cursor cursor, ViewGroup parent) {
             return mInflater.inflate(R.layout.education_cell, parent, false);
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            long mTime		= cursor.getLong(cursor.getColumnIndex(KOResumeProviderMetaData.EducationTableMetaData.EARNED_DATE));
            String name		= cursor.getString(cursor.getColumnIndex(KOResumeProviderMetaData.EducationTableMetaData.NAME));
            String title	= cursor.getString(cursor.getColumnIndex(KOResumeProviderMetaData.EducationTableMetaData.TITLE));

            Calendar cal = Calendar.getInstance();
            cal.setTimeInMillis(mTime);

            String format = "MMM yyyy";
            SimpleDateFormat sdf = new SimpleDateFormat(format);
            String dateString = sdf.format(cal.getTime());
            
            Log.d(TAG, "dateString = " + dateString);

            ((TextView) view.findViewById(R.id.eduName)).setText(name);
            ((TextView) view.findViewById(R.id.eduTitle)).setText(title);
            ((TextView) view.findViewById(R.id.eduDate)).setText(dateString);
        }
    }

    private void deleteEducation(long itemId) {
    	ContentResolver contentResolver = this.getContentResolver();
    	Uri uri = EducationTableMetaData.CONTENT_URI;
    	Uri delUri = Uri.withAppendedPath(uri, Integer.toString((int) itemId));
    	Log.d(TAG, "delUri = " + delUri);
    	contentResolver.delete(delUri, null, null);
    	
    	// Redraw the listView
    	// TODO - there may be a more elegant way of doing this
    	populateEducation(mResumeId);
    }
}
