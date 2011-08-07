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
import android.provider.BaseColumns;
import android.text.TextUtils;
import android.util.Log;

import com.kevingomara.koresume.KOResumeProviderMetaData.AccomplishmentsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.EducationTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.JobsTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class KOResumeProvider extends ContentProvider {

	/**
	 * Create the Database
	 */
	private static class DatabaseHelper extends SQLiteOpenHelper {
		DatabaseHelper(Context context) {
			super(context, KOResumeProviderMetaData.DATABASE_NAME, null, KOResumeProviderMetaData.DATABASE_VERSION);
		}
		
		@Override
		public void onCreate(SQLiteDatabase db) {
			Log.d(TAG, "inner onCreate called");
			db.execSQL("CREATE TABLE " + PackageTableMetaData.TABLE_NAME + " ("
					+ PackageTableMetaData._ID 			+ " INTEGER PRIMARY KEY,"
					+ PackageTableMetaData.CREATED_DATE + " INTEGER,"
					+ PackageTableMetaData.NAME 		+ " TEXT,"
					+ PackageTableMetaData.COVER_LTR	+ " TEXT,"
					+ PackageTableMetaData.RESUME_ID 	+ " INTEGER" + ");");
			db.execSQL("CREATE TABLE " + ResumeTableMetaData.TABLE_NAME + " ("
					+ ResumeTableMetaData._ID 			+ " INTEGER PRIMARY KEY,"
					+ ResumeTableMetaData.CREATED_DATE 	+ " INTEGER,"
					+ ResumeTableMetaData.NAME	 		+ " TEXT,"
					+ ResumeTableMetaData.SUMMARY		+ " TEXT,"
					+ ResumeTableMetaData.PACKAGE_ID 	+ " INTEGER,"
					+ ResumeTableMetaData.STREET1		+ " TEXT,"
					+ ResumeTableMetaData.STREET2		+ " TEXT,"
					+ ResumeTableMetaData.CITY		 	+ " TEXT,"
					+ ResumeTableMetaData.STATE 		+ " TEXT,"
					+ ResumeTableMetaData.POSTAL_CODE	+ " TEXT,"
					+ ResumeTableMetaData.HOME_PHONE	+ " TEXT,"
					+ ResumeTableMetaData.MOBILE_PHONE 	+ " TEXT," 
					+ "FOREIGN KEY (" + ResumeTableMetaData.PACKAGE_ID + ") "
					+ "REFERENCES " + PackageTableMetaData.TABLE_NAME 
					+ " (" + PackageTableMetaData._ID + "));");
			db.execSQL("CREATE TABLE " + JobsTableMetaData.TABLE_NAME + " ("
					+ JobsTableMetaData._ID 			+ " INTEGER PRIMARY KEY,"
					+ JobsTableMetaData.CREATED_DATE 	+ " INTEGER,"
					+ JobsTableMetaData.NAME	 		+ " TEXT,"
					+ JobsTableMetaData.SUMMARY			+ " TEXT,"
					+ JobsTableMetaData.RESUME_ID 		+ " INTEGER,"
					+ JobsTableMetaData.URI				+ " TEXT,"
					+ JobsTableMetaData.START_DATE		+ " INTEGER,"
					+ JobsTableMetaData.END_DATE		+ " INTEGER,"
					+ JobsTableMetaData.TITLE			+ " TEXT,"
					+ JobsTableMetaData.CITY		 	+ " TEXT,"
					+ JobsTableMetaData.STATE 			+ " TEXT,"
					+ "FOREIGN KEY (" + JobsTableMetaData.RESUME_ID + ") "
					+ "REFERENCES " + ResumeTableMetaData.TABLE_NAME 
					+ " (" + ResumeTableMetaData._ID + "));");
			db.execSQL("CREATE TABLE " + AccomplishmentsTableMetaData.TABLE_NAME + " ("
					+ AccomplishmentsTableMetaData._ID 				+ " INTEGER PRIMARY KEY,"
					+ AccomplishmentsTableMetaData.CREATED_DATE 	+ " INTEGER,"
					+ AccomplishmentsTableMetaData.NAME	 			+ " TEXT,"
					+ AccomplishmentsTableMetaData.SUMMARY			+ " TEXT,"
					+ AccomplishmentsTableMetaData.JOBS_ID 			+ " INTEGER,"
					// TODO figure out why autoincrement doesn't work
					+ AccomplishmentsTableMetaData.SEQUENCE_NUMBER	+ " INTEGER AUTO INCREMENT,"
					+ "FOREIGN KEY (" + AccomplishmentsTableMetaData.JOBS_ID + ") "
					+ "REFERENCES " + JobsTableMetaData.TABLE_NAME 
					+ " (" + JobsTableMetaData._ID + "));");
			db.execSQL("CREATE TABLE " + EducationTableMetaData.TABLE_NAME + " ("
					+ EducationTableMetaData._ID 				+ " INTEGER PRIMARY KEY,"
					+ EducationTableMetaData.CREATED_DATE 		+ " INTEGER,"
					+ EducationTableMetaData.NAME	 			+ " TEXT,"
					+ EducationTableMetaData.RESUME_ID 			+ " INTEGER,"
					+ EducationTableMetaData.TITLE				+ " TEXT,"
					+ EducationTableMetaData.CITY		 		+ " TEXT,"
					+ EducationTableMetaData.STATE 				+ " TEXT,"
					// TODO figure out why autoincrement doesn't work
					+ EducationTableMetaData.SEQUENCE_NUMBER	+ " INTEGER AUTO INCREMENT,"
					+ EducationTableMetaData.EARNED_DATE		+ " INTEGER,"
					+ "FOREIGN KEY (" + EducationTableMetaData.RESUME_ID + ") "
					+ "REFERENCES " + ResumeTableMetaData.TABLE_NAME 
					+ " (" + ResumeTableMetaData._ID + "));");
			Log.d(TAG, "onCreate() inner, db created");
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
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			/* 
			 * Placeholder for version 1 of db. 
			 */
			Log.d(TAG, "inner onUpgrade called");
			Log.w(TAG, "Upgrading db from version " + oldVersion + " to " + newVersion + ", which will destroy all data");
			db.execSQL("DROP TABLE IF EXISTS " + PackageTableMetaData.TABLE_NAME);
			onCreate(db);
		}
	}
	private static final String TAG = "KOResumeProvider";
	
	// Setup projection Maps
	private static HashMap<String, String> sPackageProjectionMap;
		
	static {
		sPackageProjectionMap = new HashMap<String, String>();
		sPackageProjectionMap.put(BaseColumns._ID,				BaseColumns._ID);
		
		// add fields
		sPackageProjectionMap.put(PackageTableMetaData.NAME, 			PackageTableMetaData.NAME);
		sPackageProjectionMap.put(PackageTableMetaData.COVER_LTR,  		PackageTableMetaData.COVER_LTR);
		sPackageProjectionMap.put(KOResumeBaseColumns.CREATED_DATE, 	KOResumeBaseColumns.CREATED_DATE);
		sPackageProjectionMap.put(PackageTableMetaData.RESUME_ID,		PackageTableMetaData.RESUME_ID);
	}
	private static HashMap<String, String> sResumeProjectionMap;
		
	static {
		sResumeProjectionMap = new HashMap<String, String>();
		sResumeProjectionMap.put(BaseColumns._ID,			BaseColumns._ID);
		
		// add fields
		sResumeProjectionMap.put(ResumeTableMetaData.NAME,			ResumeTableMetaData.NAME);
		sResumeProjectionMap.put(ResumeTableMetaData.SUMMARY, 		ResumeTableMetaData.SUMMARY);
		sResumeProjectionMap.put(KOResumeBaseColumns.CREATED_DATE,	KOResumeBaseColumns.CREATED_DATE);
		sResumeProjectionMap.put(ResumeTableMetaData.PACKAGE_ID,	ResumeTableMetaData.PACKAGE_ID);
		sResumeProjectionMap.put(ResumeTableMetaData.STREET1,		ResumeTableMetaData.STREET1);
		sResumeProjectionMap.put(ResumeTableMetaData.STREET2,		ResumeTableMetaData.STREET2);
		sResumeProjectionMap.put(ResumeTableMetaData.CITY,			ResumeTableMetaData.CITY);
		sResumeProjectionMap.put(ResumeTableMetaData.STATE,			ResumeTableMetaData.STATE);
		sResumeProjectionMap.put(ResumeTableMetaData.POSTAL_CODE,	ResumeTableMetaData.POSTAL_CODE);
		sResumeProjectionMap.put(ResumeTableMetaData.HOME_PHONE,	ResumeTableMetaData.HOME_PHONE);
		sResumeProjectionMap.put(ResumeTableMetaData.MOBILE_PHONE,	ResumeTableMetaData.MOBILE_PHONE);
	}
	private static HashMap<String, String> sJobsProjectionMap;
		
	static {
		sJobsProjectionMap = new HashMap<String, String>();
		sJobsProjectionMap.put(BaseColumns._ID,			BaseColumns._ID);
		
		// add fields
		sJobsProjectionMap.put(JobsTableMetaData.NAME,			JobsTableMetaData.NAME);
		sJobsProjectionMap.put(JobsTableMetaData.SUMMARY, 		JobsTableMetaData.SUMMARY);
		sJobsProjectionMap.put(KOResumeBaseColumns.CREATED_DATE,	KOResumeBaseColumns.CREATED_DATE);
		sJobsProjectionMap.put(JobsTableMetaData.RESUME_ID,		JobsTableMetaData.RESUME_ID);
		sJobsProjectionMap.put(JobsTableMetaData.URI,			JobsTableMetaData.URI);
		sJobsProjectionMap.put(JobsTableMetaData.TITLE,			JobsTableMetaData.TITLE);
		sJobsProjectionMap.put(JobsTableMetaData.CITY,			JobsTableMetaData.CITY);
		sJobsProjectionMap.put(JobsTableMetaData.STATE,			JobsTableMetaData.STATE);
		sJobsProjectionMap.put(JobsTableMetaData.START_DATE,	JobsTableMetaData.START_DATE);
		sJobsProjectionMap.put(JobsTableMetaData.END_DATE,		JobsTableMetaData.END_DATE);
	}
	private static HashMap<String, String> sAccomplishmentsProjectionMap;
		
	static {
		sAccomplishmentsProjectionMap = new HashMap<String, String>();
		sAccomplishmentsProjectionMap.put(BaseColumns._ID,				BaseColumns._ID);
		
		// add fields
		sAccomplishmentsProjectionMap.put(AccomplishmentsTableMetaData.NAME,			AccomplishmentsTableMetaData.NAME);
		sAccomplishmentsProjectionMap.put(AccomplishmentsTableMetaData.SUMMARY, 		AccomplishmentsTableMetaData.SUMMARY);
		sAccomplishmentsProjectionMap.put(KOResumeBaseColumns.CREATED_DATE,	KOResumeBaseColumns.CREATED_DATE);
		sAccomplishmentsProjectionMap.put(AccomplishmentsTableMetaData.SEQUENCE_NUMBER,	AccomplishmentsTableMetaData.SEQUENCE_NUMBER);
		sAccomplishmentsProjectionMap.put(AccomplishmentsTableMetaData.JOBS_ID,			AccomplishmentsTableMetaData.JOBS_ID);
	}
	private static HashMap<String, String> sEducationProjectionMap;
		
	static {
		sEducationProjectionMap = new HashMap<String, String>();
		sEducationProjectionMap.put(EducationTableMetaData._ID,				BaseColumns._ID);
		
		// add fields
		sEducationProjectionMap.put(EducationTableMetaData.NAME,			EducationTableMetaData.NAME);
		sEducationProjectionMap.put(EducationTableMetaData.CREATED_DATE,	EducationTableMetaData.CREATED_DATE);
		sEducationProjectionMap.put(EducationTableMetaData.RESUME_ID,		EducationTableMetaData.RESUME_ID);
		sEducationProjectionMap.put(EducationTableMetaData.TITLE,			EducationTableMetaData.TITLE);
		sEducationProjectionMap.put(EducationTableMetaData.SEQUENCE_NUMBER,	EducationTableMetaData.SEQUENCE_NUMBER);
		sEducationProjectionMap.put(EducationTableMetaData.CITY,			EducationTableMetaData.CITY);
		sEducationProjectionMap.put(EducationTableMetaData.STATE,			EducationTableMetaData.STATE);
		sEducationProjectionMap.put(EducationTableMetaData.EARNED_DATE,		EducationTableMetaData.EARNED_DATE);
	}
	//Provide a mechanism to identify all the incoming Uri patterns
	private static final UriMatcher sUriMatcher;
	private static final int IN_SINGLE_PACKAGE_URI_INDICATOR 				=  1;
	private static final int IN_PACKAGE_COLLECTION_URI_INDICATOR 			=  2;
	private static final int IN_SINGLE_RESUME_URI_INDICATOR 				=  3;
	private static final int IN_RESUME_COLLECTION_URI_INDICATOR 			=  4;
	private static final int IN_SINGLE_JOBS_URI_INDICATOR 					=  5;
	private static final int IN_JOBS_COLLECTION_URI_INDICATOR 				=  6;
	private static final int IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR 		=  7;
	private static final int IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR	=  8;
	private static final int IN_SINGLE_EDUCATION_URI_INDICATOR 				=  9;
	private static final int IN_EDUCATION_COLLECTION_URI_INDICATOR 			= 10;
	
	static {
		sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.PACKAGE_TABLE_NAME, 		
							IN_PACKAGE_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.PACKAGE_TABLE_NAME + "/#", 	
							IN_SINGLE_PACKAGE_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.RESUME_TABLE_NAME, 			
							IN_RESUME_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.RESUME_TABLE_NAME  + "/#", 	
							IN_SINGLE_RESUME_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.JOBS_TABLE_NAME, 			
							IN_JOBS_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.JOBS_TABLE_NAME  + "/#", 	
							IN_SINGLE_JOBS_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.ACCOMPLISHMENTS_TABLE_NAME, 			
							IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.ACCOMPLISHMENTS_TABLE_NAME  + "/#", 	
							IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.EDUCATION_TABLE_NAME, 			
							IN_EDUCATION_COLLECTION_URI_INDICATOR);
		sUriMatcher.addURI(	KOResumeProviderMetaData.AUTHORITY, 
							KOResumeProviderMetaData.EDUCATION_TABLE_NAME  + "/#", 	
							IN_SINGLE_EDUCATION_URI_INDICATOR);
	}
	
	private DatabaseHelper mOpenHelper;
		
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		int count = 0;
		
		switch (sUriMatcher.match(uri)) {
		case IN_SINGLE_PACKAGE_URI_INDICATOR: {
			String packageId = uri.getPathSegments().get(1);
			count = db.delete(PackageTableMetaData.TABLE_NAME,
						PackageTableMetaData._ID + "=" + packageId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		}
		case IN_SINGLE_RESUME_URI_INDICATOR: {
			String resumeId = uri.getPathSegments().get(1);
			count = db.delete(ResumeTableMetaData.TABLE_NAME,
						ResumeTableMetaData._ID + "=" + resumeId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		}
		case IN_SINGLE_JOBS_URI_INDICATOR: {
			String jobsId = uri.getPathSegments().get(1);
			count = db.delete(JobsTableMetaData.TABLE_NAME,
						JobsTableMetaData._ID + "=" + jobsId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		}
		case IN_JOBS_COLLECTION_URI_INDICATOR: {
			if (TextUtils.isEmpty(selection) || !(selectionArgs.length > 0)) {
				throw new IllegalArgumentException("selection and arguments are required");
			}
			count = db.delete(JobsTableMetaData.TABLE_NAME,
					selection,
					selectionArgs);
			break;
		}
		case IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR: {
			String accomplishmentsId = uri.getPathSegments().get(1);
			count = db.delete(AccomplishmentsTableMetaData.TABLE_NAME,
						AccomplishmentsTableMetaData._ID + "=" + accomplishmentsId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		}
		case IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR: {
			if (TextUtils.isEmpty(selection) || !(selectionArgs.length > 0)) {
				throw new IllegalArgumentException("selection and arguments are required");
			}
			count = db.delete(AccomplishmentsTableMetaData.TABLE_NAME,
					selection,
					selectionArgs);
			break;
		}
		case IN_SINGLE_EDUCATION_URI_INDICATOR: {
			String educationId = uri.getPathSegments().get(1);
			count = db.delete(EducationTableMetaData.TABLE_NAME,
						EducationTableMetaData._ID + "=" + educationId + (!TextUtils.isEmpty(selection) ? "AND (" + selection + ')' : ""),
						selectionArgs);
			break;
		}
		case IN_EDUCATION_COLLECTION_URI_INDICATOR: {
			if (TextUtils.isEmpty(selection) || !(selectionArgs.length > 0)) {
				throw new IllegalArgumentException("selection and arguments are required");
			}
			count = db.delete(EducationTableMetaData.TABLE_NAME,
					selection,
					selectionArgs);
			break;
		}
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
			// Fall through to next case
		case IN_PACKAGE_COLLECTION_URI_INDICATOR:
			return PackageTableMetaData.CONTENT_ITEM_TYPE;

		case IN_SINGLE_RESUME_URI_INDICATOR:
			// Fall through to next case
		case IN_RESUME_COLLECTION_URI_INDICATOR:
			return ResumeTableMetaData.CONTENT_ITEM_TYPE;

		case IN_SINGLE_JOBS_URI_INDICATOR:
			// Fall through to next case
		case IN_JOBS_COLLECTION_URI_INDICATOR:
			return ResumeTableMetaData.CONTENT_ITEM_TYPE;

		case IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR:
			// Fall through to next case
		case IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR:
			return ResumeTableMetaData.CONTENT_ITEM_TYPE;

		case IN_SINGLE_EDUCATION_URI_INDICATOR:
			// Fall through to next case
		case IN_EDUCATION_COLLECTION_URI_INDICATOR:
			return ResumeTableMetaData.CONTENT_ITEM_TYPE;

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
		if (values.containsKey(KOResumeBaseColumns.CREATED_DATE) == false) {
			values.put(KOResumeBaseColumns.CREATED_DATE, now);
		}

		// Get a writable database
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();

		// Validate the Uri is for a single item
		switch (sUriMatcher.match(uri)) {
		case IN_PACKAGE_COLLECTION_URI_INDICATOR: {
			if (values.containsKey(PackageTableMetaData.NAME) == false) {
				throw new SQLException("insert() Failed to insert package, Name is required" + uri);
			}
			// Insert the package
			long rowId = db.insert(PackageTableMetaData.TABLE_NAME, PackageTableMetaData.NAME, values);
			
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
//			if (values.containsKey(ResumeTableMetaData.NAME) == false) {
//				throw new SQLException("insert() Failed to insert resume, Name is required" + uri);
//			}

			// Insert the package
			long rowId = db.insert(ResumeTableMetaData.TABLE_NAME, ResumeTableMetaData.NAME, values);
			
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
		case IN_JOBS_COLLECTION_URI_INDICATOR: {
//			if (values.containsKey(JobsTableMetaData.NAME) == false) {
//				throw new SQLException("insert() Failed to insert job, Name is required" + uri);
//			}

			// Insert the package
			long rowId = db.insert(JobsTableMetaData.TABLE_NAME, JobsTableMetaData.NAME, values);
			
			// If the insert is successful, notify the calling context
			if (rowId > 0) {
				Uri insertedJobsUri = ContentUris.withAppendedId(JobsTableMetaData.CONTENT_URI, rowId);
				getContext().getContentResolver().notifyChange(insertedJobsUri, null);
				return insertedJobsUri;
			} else {
				throw new SQLException("insert() Failed to insert row into " + uri);
			}
		}
		case IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR: {
			if (values.containsKey(AccomplishmentsTableMetaData.NAME) == false) {
				throw new SQLException("insert() Failed to insert accomplishment, Name is required" + uri);
			}

			// Insert the package
			long rowId = db.insert(AccomplishmentsTableMetaData.TABLE_NAME, AccomplishmentsTableMetaData.NAME, values);
			
			// If the insert is successful, notify the calling context
			if (rowId > 0) {
				Uri insertedAccomplishmentsUri = ContentUris.withAppendedId(AccomplishmentsTableMetaData.CONTENT_URI, rowId);
				getContext().getContentResolver().notifyChange(insertedAccomplishmentsUri, null);
				return insertedAccomplishmentsUri;
			} else {
				throw new SQLException("insert() Failed to insert row into " + uri);
			}
		}
		case IN_EDUCATION_COLLECTION_URI_INDICATOR: {
			if (values.containsKey(EducationTableMetaData.NAME) == false) {
				throw new SQLException("insert() Failed to insert education, Name is required" + uri);
			}

			// Insert the package
			long rowId = db.insert(EducationTableMetaData.TABLE_NAME, EducationTableMetaData.NAME, values);
			
			// If the insert is successful, notify the calling context
			if (rowId > 0) {
				Uri insertedEducationUri = ContentUris.withAppendedId(EducationTableMetaData.CONTENT_URI, rowId);
				getContext().getContentResolver().notifyChange(insertedEducationUri, null);
				return insertedEducationUri;
			} else {
				throw new SQLException("insert() Failed to insert row into " + uri);
			}
		}
		default:
			throw new IllegalArgumentException("insert() Unknown URI " + uri);			
		}
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
		case IN_SINGLE_PACKAGE_URI_INDICATOR: {
			qb.setTables(PackageTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sPackageProjectionMap);
			qb.appendWhere(PackageTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = PackageTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_PACKAGE_COLLECTION_URI_INDICATOR: {
			qb.setTables(PackageTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sPackageProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = PackageTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_SINGLE_RESUME_URI_INDICATOR: {
			qb.setTables(ResumeTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sResumeProjectionMap);
			qb.appendWhere(ResumeTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = ResumeTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_RESUME_COLLECTION_URI_INDICATOR: {
			qb.setTables(ResumeTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sResumeProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = ResumeTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_SINGLE_JOBS_URI_INDICATOR: {
			qb.setTables(JobsTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sJobsProjectionMap);
			qb.appendWhere(JobsTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = JobsTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_JOBS_COLLECTION_URI_INDICATOR: {
			qb.setTables(JobsTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sJobsProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = JobsTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR: {
			qb.setTables(AccomplishmentsTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sAccomplishmentsProjectionMap);
			qb.appendWhere(AccomplishmentsTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = AccomplishmentsTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_ACCOMPLISHMENTS_COLLECTION_URI_INDICATOR: {
			qb.setTables(AccomplishmentsTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sAccomplishmentsProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = AccomplishmentsTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_SINGLE_EDUCATION_URI_INDICATOR: {
			qb.setTables(EducationTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sEducationProjectionMap);
			qb.appendWhere(EducationTableMetaData._ID + "=" + uri.getPathSegments().get(1));
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = EducationTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
		case IN_EDUCATION_COLLECTION_URI_INDICATOR: {
			qb.setTables(EducationTableMetaData.TABLE_NAME);
			qb.setProjectionMap(sEducationProjectionMap);
			if (TextUtils.isEmpty(sortOrder)) {
				orderBy = EducationTableMetaData.DEFAULT_SORT_ORDER;
			}
			break;
		}
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
		case IN_SINGLE_PACKAGE_URI_INDICATOR: {
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(PackageTableMetaData.TABLE_NAME, values, 
					PackageTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		}
		case IN_SINGLE_RESUME_URI_INDICATOR: {
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(ResumeTableMetaData.TABLE_NAME, values, 
					ResumeTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		}
		case IN_SINGLE_JOBS_URI_INDICATOR: {
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(JobsTableMetaData.TABLE_NAME, values, 
					JobsTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		}
		case IN_SINGLE_ACCOMPLISHMENTS_URI_INDICATOR: {
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(AccomplishmentsTableMetaData.TABLE_NAME, values, 
					AccomplishmentsTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		}
		case IN_SINGLE_EDUCATION_URI_INDICATOR: {
			String rowId = uri.getPathSegments().get(1);
			Log.d(TAG, "rowId = " + rowId);
			count = db.update(EducationTableMetaData.TABLE_NAME, values, 
					EducationTableMetaData._ID + "=" + rowId + (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : ""), 
					selectionArgs);
			break;
		}
		default:
			throw new IllegalArgumentException("update() Unknown Uri " + uri);			
		}

		getContext().getContentResolver().notifyChange(uri, null);
		
		return count;
	}

	private void updatePackageWithResumeId(long resumeId, Uri uri) {
		Uri insertedPackageUri = ContentUris.withAppendedId( PackageTableMetaData.CONTENT_URI, resumeId);

		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.RESUME_ID, resumeId);

		update(insertedPackageUri, contentValues, null, null);
	}
}
