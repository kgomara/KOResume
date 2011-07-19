package com.kevingomara.koresume;

import java.util.HashMap;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class KOResumeProvider extends ContentProvider {

	private static final String TAG = "KOResumeProvider";
	private static Context mContext = null;
	
	// Setup projection Maps
	private static HashMap<String, String> sPackageProjectionMap;
	static {
		sPackageProjectionMap = new HashMap<String, String>();
		sPackageProjectionMap.put(PackageTableMetaData._ID,				PackageTableMetaData._ID);
		
		// add fields
		sPackageProjectionMap.put(PackageTableMetaData.PACKAGE_NAME, 	PackageTableMetaData.PACKAGE_NAME);
		sPackageProjectionMap.put(PackageTableMetaData.COVER_LTR,  		PackageTableMetaData.COVER_LTR);
		sPackageProjectionMap.put(PackageTableMetaData.CREATED_DATE, 	PackageTableMetaData.CREATED_DATE);
		sPackageProjectionMap.put(PackageTableMetaData.RESUME_ID,		PackageTableMetaData.RESUME_ID);
	}
		
	private static HashMap<String, String> sResumeProjectionMap;
	static {
		sResumeProjectionMap = new HashMap<String, String>();
		sResumeProjectionMap.put(ResumeTableMetaData._ID,				ResumeTableMetaData._ID);
		
		// add fields
		sResumeProjectionMap.put(ResumeTableMetaData.RESUME_NAME,		ResumeTableMetaData.RESUME_NAME);
		sResumeProjectionMap.put(ResumeTableMetaData.SUMMARY_TEXT, 		ResumeTableMetaData.SUMMARY_TEXT);
		sResumeProjectionMap.put(ResumeTableMetaData.CREATED_DATE,		ResumeTableMetaData.CREATED_DATE);
		sResumeProjectionMap.put(ResumeTableMetaData.PACKAGE_ID,		ResumeTableMetaData.PACKAGE_ID);
		sResumeProjectionMap.put(ResumeTableMetaData.STREET1,			ResumeTableMetaData.STREET1);
		sResumeProjectionMap.put(ResumeTableMetaData.STREET2,			ResumeTableMetaData.STREET2);
		sResumeProjectionMap.put(ResumeTableMetaData.CITY,				ResumeTableMetaData.CITY);
		sResumeProjectionMap.put(ResumeTableMetaData.STATE,				ResumeTableMetaData.STATE);
		sResumeProjectionMap.put(ResumeTableMetaData.POSTAL_CODE,		ResumeTableMetaData.POSTAL_CODE);
		sResumeProjectionMap.put(ResumeTableMetaData.HOME_PHONE,		ResumeTableMetaData.HOME_PHONE);
		sResumeProjectionMap.put(ResumeTableMetaData.MOBILE_PHONE,		ResumeTableMetaData.MOBILE_PHONE);
	}
		
	//Provide a mechanism to identify all the incoming Uri patterns
	private static final UriMatcher sUriMatcher;
	private static final int IN_SINGLE_PACKAGE_URI_INDICATOR 		= 1;
	private static final int IN_PACKAGE_COLLECTION_URI_INDICATOR 	= 2;
	private static final int IN_SINGLE_RESUME_URI_INDICATOR 		= 3;
	private static final int IN_RESUME_COLLECTION_URI_INDICATOR 	= 4;
	static {
		sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
		sUriMatcher.addURI(KOResumeProviderMetaData.AUTHORITY, KOResumeProviderMetaData.PACKAGE_TABLE_NAME, 		IN_PACKAGE_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(KOResumeProviderMetaData.AUTHORITY, KOResumeProviderMetaData.PACKAGE_TABLE_NAME + "/#", 	IN_SINGLE_PACKAGE_URI_INDICATOR);
		sUriMatcher.addURI(KOResumeProviderMetaData.AUTHORITY, KOResumeProviderMetaData.RESUME_TABLE_NAME, 			IN_RESUME_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(KOResumeProviderMetaData.AUTHORITY, KOResumeProviderMetaData.RESUME_TABLE_NAME  + "/#", 	IN_SINGLE_RESUME_URI_INDICATOR);
	}
	
	/**
	 * Create the Database
	 */
	private static class DatabaseHelper extends SQLiteOpenHelper {
		DatabaseHelper(Context context) {
			super(context, KOResumeProviderMetaData.DATABASE_NAME, null, KOResumeProviderMetaData.DATABASE_VERSION);
			mContext = context;
		}
		
		@Override
		  public void onOpen(SQLiteDatabase db)
		  {
		    super.onOpen(db);
		    if (!db.isReadOnly())
		    {
		      // Enable foreign key constraints
		      db.execSQL("PRAGMA foreign_keys=ON;");
		    }
		  }
		
		@Override
		public void onCreate(SQLiteDatabase db) {
			Log.d(TAG, "inner onCreate called");
			db.execSQL("CREATE TABLE " + PackageTableMetaData.TABLE_NAME + " ("
					+ PackageTableMetaData._ID 				+ " INTEGER PRIMARY KEY,"
					+ PackageTableMetaData.PACKAGE_NAME 	+ " TEXT,"
					+ PackageTableMetaData.COVER_LTR		+ " TEXT,"
					+ PackageTableMetaData.CREATED_DATE 	+ " INTEGER,"
					+ PackageTableMetaData.RESUME_ID 		+ " INTEGER" + ");");
			db.execSQL("CREATE TABLE " + ResumeTableMetaData.TABLE_NAME + " ("
					+ ResumeTableMetaData._ID 				+ " INTEGER PRIMARY KEY,"
					+ ResumeTableMetaData.RESUME_NAME	 	+ " TEXT,"
					+ ResumeTableMetaData.SUMMARY_TEXT		+ " TEXT,"
					+ ResumeTableMetaData.CREATED_DATE 		+ " INTEGER,"
					+ ResumeTableMetaData.PACKAGE_ID 		+ " INTEGER,"
					// TODO - figure out why FOREIGN_KEYS isn't working
//					+ "FOREIGN KEY(" + ResumeTableMetaData.PACKAGE_ID + ") REFERENCES " + PackageTableMetaData.TABLE_NAME + "(" + PackageTableMetaData._ID + "),"
					+ ResumeTableMetaData.STREET1		 	+ " TEXT,"
					+ ResumeTableMetaData.STREET2			+ " TEXT,"
					+ ResumeTableMetaData.CITY		 		+ " TEXT,"
					+ ResumeTableMetaData.STATE 			+ " TEXT,"
					+ ResumeTableMetaData.POSTAL_CODE	 	+ " TEXT,"
					+ ResumeTableMetaData.HOME_PHONE		+ " TEXT,"
					+ ResumeTableMetaData.MOBILE_PHONE 		+ " TEXT" + ");");
			Log.d(TAG, "onCreate() inner, db created");
		}
		
		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			Log.d(TAG, "inner onUpgrade called");
			Log.w(TAG, "Upgrading db from version " + oldVersion + " to " + newVersion + ", which will destroy all data");
			db.execSQL("DROP TABLE IF EXISTS " + PackageTableMetaData.TABLE_NAME);
			onCreate(db);
		}
	}
	
	private DatabaseHelper mOpenHelper;
		
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		int count = 0;
		
		switch (sUriMatcher.match(uri)) {
		case IN_SINGLE_PACKAGE_URI_INDICATOR:
			String packageId = uri.getPathSegments().get(1);
			count = db.delete(PackageTableMetaData.TABLE_NAME,
						PackageTableMetaData._ID + "=" + packageId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		default:
			throw new IllegalArgumentException("delete() Unknown URI " + uri);
		}
		
		getContext().getContentResolver().notifyChange(uri, null);
		
		return count;
	}

	@Override
	public String getType(Uri uri) {
		switch (sUriMatcher.match(uri)) {
		case IN_SINGLE_PACKAGE_URI_INDICATOR:
			return PackageTableMetaData.CONTENT_ITEM_TYPE;
		default:
			throw new IllegalArgumentException("getType() Unknown URI " + uri);
		}
	}

	@Override
	public Uri insert(Uri uri, ContentValues initialValues) {
		// Validate ContentValues
		ContentValues values;
		if (initialValues != null) {
			values = new ContentValues(initialValues);
		} else {
			values = new ContentValues();
		}
		
		// Validate the fields
		Long now = Long.valueOf(System.currentTimeMillis());
		if (values.containsKey(KOResumeProviderMetaData.CREATED_DATE) == false) {
			values.put(KOResumeProviderMetaData.CREATED_DATE, now);
		}

		// Get a writable database
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();

		// Validate the Uri is for a single item
		switch (sUriMatcher.match(uri)) {
		case IN_PACKAGE_COLLECTION_URI_INDICATOR: {
			if (values.containsKey(PackageTableMetaData.PACKAGE_NAME) == false) {
				throw new SQLException("insert() Failed to insert package, Name is required" + uri);
			}
			// Insert the package
			long rowId = db.insert(PackageTableMetaData.TABLE_NAME, PackageTableMetaData.PACKAGE_NAME, values);
			
			// If the insert is successful, notify the calling context
			if (rowId > 0) {
				Uri insertedPackageUri = ContentUris.withAppendedId(PackageTableMetaData.CONTENT_URI, rowId);
				getContext().getContentResolver().notifyChange(insertedPackageUri, null);
				return insertedPackageUri;
			} else {
				throw new SQLException("insert() Failed to insert row into " + uri);
			}
		}
		case IN_RESUME_COLLECTION_URI_INDICATOR: {
			if (values.containsKey(ResumeTableMetaData.RESUME_NAME) == false) {
				throw new SQLException("insert() Failed to insert resume, Name is required" + uri);
			}
			if (values.containsKey(ResumeTableMetaData.PACKAGE_ID) == false) {
				// TODO may be able to eliminate this check if Foreign keys work
				throw new SQLException("insert() Failed to insert resume, PackageId is required" + uri);
			} else {
				// TODO - need to confirm PACKAGE_ID exists?
			}
			// Insert the package
			long rowId = db.insert(ResumeTableMetaData.TABLE_NAME, ResumeTableMetaData.RESUME_NAME, values);
			
			// If the insert is successful, notify the calling context
			if (rowId > 0) {
				Uri insertedResumeUri = ContentUris.withAppendedId(ResumeTableMetaData.CONTENT_URI, rowId);
				getContext().getContentResolver().notifyChange(insertedResumeUri, null);
				updatePackageWithResumeId(rowId, uri);
				return insertedResumeUri;
			} else {
				throw new SQLException("insert() Failed to insert row into " + uri);
			}
		}
		default:
			throw new IllegalArgumentException("insert() Unknown URI " + uri);			
		}
	}
	
	private void updatePackageWithResumeId(long resumeId, Uri uri) {
		Uri insertedPackageUri = ContentUris.withAppendedId( PackageTableMetaData.CONTENT_URI, resumeId);

		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.RESUME_ID, resumeId);

		update(insertedPackageUri, contentValues, null, null);
	}

	@Override
	public boolean onCreate() {
		Log.d(TAG, "main onCreate called");
		mOpenHelper = new DatabaseHelper(getContext());
		
		return true;
	}

	@Override
	public Cursor query(Uri uri, String[] projection, String selection, 
			String[] selectionArgs, String sortOrder) {

		String orderBy = sortOrder;
		SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
		Log.d(TAG, "query(), uri = " + uri);
		
		switch (sUriMatcher.match(uri)) {
		case IN_SINGLE_PACKAGE_URI_INDICATOR:
			qb.setTables(PackageTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sPackageProjectionMap);
			qb.appendWhere(PackageTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = PackageTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		case IN_PACKAGE_COLLECTION_URI_INDICATOR:
			qb.setTables(PackageTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sPackageProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = PackageTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		case IN_SINGLE_RESUME_URI_INDICATOR:
			qb.setTables(ResumeTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sResumeProjectionMap);
			qb.appendWhere(ResumeTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = ResumeTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		case IN_RESUME_COLLECTION_URI_INDICATOR:
			qb.setTables(ResumeTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sResumeProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = ResumeTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		default:
			throw new IllegalArgumentException("query() Unknown Uri " + uri);
		}
		
		// Get the database and run the query
		SQLiteDatabase db = mOpenHelper.getReadableDatabase();
		Cursor cursor = qb.query(db, projection, selection, selectionArgs, null, null, orderBy);
		
		// Tell the cursor which uri to watch
		cursor.setNotificationUri(getContext().getContentResolver(), uri);
		
		return cursor;
	}

	@Override
	public int update(Uri uri, ContentValues values, String selection,
			String[] selectionArgs) {
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		int count = 0;
		switch (sUriMatcher.match(uri)) {
		case IN_SINGLE_PACKAGE_URI_INDICATOR:
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(PackageTableMetaData.TABLE_NAME, values, 
					PackageTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		default:
			throw new IllegalArgumentException("update() Unknown Uri " + uri);			
		}

		getContext().getContentResolver().notifyChange(uri, null);
		
		return count;
	}
}
