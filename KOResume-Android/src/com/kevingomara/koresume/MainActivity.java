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
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;

public class MainActivity extends Activity /* implements OnItemClickListener */ {
	
	private static final String TAG = "MainActivity";
	private Context mContext = this;
	private boolean isFirstTry = true;
	
	ListView listView = null;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        // Get the ListView
        listView = (ListView) findViewById(R.id.listView);

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
    		listView.setAdapter(adapter);
    		listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
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