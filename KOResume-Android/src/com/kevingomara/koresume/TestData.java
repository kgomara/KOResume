package com.kevingomara.koresume;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.res.Resources;
import android.net.Uri;
import android.util.Log;

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;
import com.kevingomara.koresume.KOResumeProviderMetaData.ResumeTableMetaData;

public class TestData {

	private static final String TAG	= "TestData";
	private Context mContext		= null;
	private int mPackageId			= 0;
	private int mResumeId			= 0;
	
	public TestData(Context context) {
		mContext = context;
	}
	
	public void create() {
		mPackageId = insertTestPackage();
		mResumeId = insertTestResume(mPackageId);
		Log.v(TAG, "resumeId = " + mResumeId);
	}
	
	private int insertTestPackage() {
		
		String coverLtr = null;;
		try {
			coverLtr = getStringFromRawFile(mContext, R.raw.coverltrstandard);
		} catch (IOException ex) {
			Log.e(TAG, "Error, could not create test package");
			ex.printStackTrace();
		}
		
		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.NAME, "Kevin O\'Mara");
		contentValues.put(KOResumeProviderMetaData.PackageTableMetaData.COVER_LTR, coverLtr);
	
		ContentResolver contentResolver = mContext.getContentResolver();
		Uri uri = PackageTableMetaData.CONTENT_URI;
		Uri insertedUri = contentResolver.insert(uri, contentValues);
		
		return Integer.parseInt(insertedUri.getPathSegments().get(1));
	}
	
	private int insertTestResume(int packageId) {
		
		String summaryText = null;
		try {
			summaryText = getStringFromRawFile(mContext, R.raw.summary);
		} catch (IOException ex) {
			Log.e(TAG, "Error, could not create test resume");
			ex.printStackTrace();			
		}
		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.NAME, 	"Kevin O\'Mara");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.SUMMARY,	summaryText);
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.PACKAGE_ID,		mPackageId);
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.STREET1, 		"1406 Marsh Harbour Dr");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.CITY, 			"Austin");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.STATE,			"TX");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.POSTAL_CODE,		"78664");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.HOME_PHONE, 		"(512) 382-6880");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.MOBILE_PHONE, 	"(415) 794-5286");
	
		ContentResolver contentResolver = mContext.getContentResolver();
		Uri uri = KOResumeProviderMetaData.ResumeTableMetaData.CONTENT_URI;
		Uri insertedUri = contentResolver.insert(uri, contentValues);
		
		return Integer.parseInt(insertedUri.getPathSegments().get(1));		
	}
	
	
	/*
	 * Helper methods start here 
	 */
	private String getStringFromRawFile(Context context, int rawResourceId) throws IOException {
		Resources resources = context.getResources();
		InputStream inputStream = resources.openRawResource(rawResourceId);
		String theText = convertStreamToString(inputStream);
		inputStream.close();
		
		return theText;
	}
	
	private String convertStreamToString(InputStream inputStream) throws IOException {
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		int i = inputStream.read();
		while (i != -1) {
			outputStream.write(i);
			i = inputStream.read();
		}
		
		return outputStream.toString();
	}
}
