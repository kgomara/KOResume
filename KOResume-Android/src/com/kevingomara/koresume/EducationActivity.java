package com.kevingomara.koresume;

import java.text.SimpleDateFormat;
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
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.ListView;
import android.widget.TextView;


public class EducationActivity extends Activity {

	private static final String TAG = "EducationActivity";
	private static final int	EDIT_ITEM	= 998;
	private static final int	DELETE_ITEM	= 999;
	
	private long 		mResumeId	= 0l;
	
	// references to the resume fields in the layout
	private ListView	mListView	= null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.education_layout);
        
        Log.v(TAG, "onCreate() called");
        
        //TODO figure out how to enable/disable editing
//		mCoverLtr.setFocusable(false); 
//		mCoverLtr.setClickable(false);
        
        // Get the jobId passed from the extras
        Bundle extras =  this.getIntent().getExtras();
        mResumeId = extras.getLong("id");
        Log.v(TAG, "jobId = " + mResumeId);
        
        // Get the ListView
        mListView	= (ListView) findViewById(R.id.educationListView);
        
        // Populate the list of accomplishments
        populateEducation(mResumeId);
    }
    
    @Override
    public void onCreateContextMenu(ContextMenu menu, View view, ContextMenuInfo menuInfo) {
    	menu.add(Menu.NONE, EDIT_ITEM, 	 Menu.NONE, R.string.editAccomplishment);
    	menu.add(Menu.NONE, DELETE_ITEM, Menu.NONE, R.string.deleteAccomplishment);
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {        // Set up the menu
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.default_menu, menu);
        
        return true;
    }
    
    @Override
    public boolean onContextItemSelected(MenuItem menuItem) {
    	
    	int itemId = menuItem.getItemId();
    	switch (itemId) {
	    	case EDIT_ITEM: {
	    		editEducation(itemId);
	    		break;
	    	}
	    	case DELETE_ITEM: {
	    		deleteEducation(itemId);
	    		break;
	    	}
    	}
    	
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
//    		saveEducation();
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
    		    	// Launch the packageActivity Intent
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

    private void editEducation(int itemId) {
    	// TODO implement
    }
    
    private void deleteEducation(int itemId) {
    	// TODO implement
    }

	private void insertEducation(String name) {
		ContentValues cv = new ContentValues();
		cv.put(KOResumeProviderMetaData.EducationTableMetaData.NAME, name);
		cv.put(KOResumeProviderMetaData.EducationTableMetaData.RESUME_ID, mResumeId);
	
		ContentResolver cr = this.getContentResolver();
		Uri uri = KOResumeProviderMetaData.EducationTableMetaData.CONTENT_URI;
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
