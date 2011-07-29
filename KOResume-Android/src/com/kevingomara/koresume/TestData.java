package com.kevingomara.koresume;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.res.Resources;
import android.net.Uri;
import android.util.Log;

import com.kevingomara.koresume.KOResumeProviderMetaData.PackageTableMetaData;

public class TestData {

	private static final String TAG	= "TestData";
	private Context mContext		= null;
	private int mPackageId			= 0;
	private int mResumeId			= 0;
	private DateFormat dateFormat	= null;
	
	public TestData(Context context) {
		mContext = context;
		dateFormat = SimpleDateFormat.getDateInstance();
	}
	
	public void create() {
		mPackageId = insertTestPackage();
		mResumeId = insertTestResume(mPackageId);
		Log.v(TAG, "resumeId = " + mResumeId);
		insertTestJobsAndAccomplishments(mResumeId);
		insertTestEducation(mResumeId);
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
	
	private void insertAppiction(int resumeId) {
		String resp = "Appiction develops mobile applications on iPhone and Android.  I led 50+ projects utilizing "
					+ "in-house, outsource, and off-shore teams.  My in-house team consisted of 16 software and "
					+ "4 QA engineers.";
		String acc1 = "Introduced Scrum (an Agile Methodology) to improve quality and predictability";
		String acc2 = "Drive on-time delievery of mobile apps implemented in Cocoa/Objective-C (C++) and Java, "
					+ "as well as their supporting websites in Django, Amazon AWS, and Google App Engine";
		String acc3 = "Sole developer of an iPhone app (Academy2GO), using RESTful interface and JSON to communicate "
					+ "with a backend WebSphere CMS.  The app configured itself based on CMS metadata, maintained a "
					+ "LRU cache cache of content objects, streamed video, and displayed several media types";
		String acc4 = "Contributed to numerous iOS and Android apps - debugging, enhancing, and performing code reviews.";
				
		int jobId = insertOneJob(	resumeId,
									"Appiction, LLC", 
									"www.appiction.com", 
									"Austin", "TX", 
									"Chief Development Officer", 
									Date.parse("06/01/2010"),
									Date.parse("06/13/2011"),
									resp);
		insertOneAccomplishment(jobId, 1, "Introduced Scrum", 	acc1);
		insertOneAccomplishment(jobId, 2, "Led Development",	acc2);
		insertOneAccomplishment(jobId, 3, "Hands-on developer",	acc3);
		insertOneAccomplishment(jobId, 4, "Technical Lead",		acc4);
	}
	
/*	private long getDateAsLong(String dateString) {
		long retVal = 0l;
		try {
			Date date = dateFormat.parse(dateString);
			Log.v(TAG, "date = " + date.toString());
			retVal = date.getTime();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return retVal;
	}
*/	
	private void insertOneAccomplishment(int jobId, int seqNum, String name, String summary) {

		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.NAME, 				name);
		contentValues.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.JOBS_ID,			jobId);
		contentValues.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.SEQUENCE_NUMBER, 	seqNum);
		contentValues.put(KOResumeProviderMetaData.AccomplishmentsTableMetaData.SUMMARY,			summary);
	
		ContentResolver contentResolver = mContext.getContentResolver();
		Uri uri = KOResumeProviderMetaData.AccomplishmentsTableMetaData.CONTENT_URI;
		contentResolver.insert(uri, contentValues);
	}
	
	private void insertOneEducation(int resumeId, int seqNum, String name, String city, String state, String title, long earnedDate) {
		
		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.NAME, 			name);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.RESUME_ID,		resumeId);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.TITLE,			title);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.CITY, 			city);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.STATE,			state);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.SEQUENCE_NUMBER, 	seqNum);
		contentValues.put(KOResumeProviderMetaData.EducationTableMetaData.EARNED_DATE, 		earnedDate);
	
		ContentResolver contentResolver = mContext.getContentResolver();
		Uri uri = KOResumeProviderMetaData.EducationTableMetaData.CONTENT_URI;
		contentResolver.insert(uri, contentValues);
	}
	
	private int insertOneJob(int resumeId, String companyName, String companyUri, 
								String companyCity, String companyState, 
								String title, long startDate, long endDate, String responsibilities) {

		ContentValues contentValues = new ContentValues();
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.NAME, 			companyName);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.SUMMARY, 		responsibilities);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.URI,			companyUri);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.RESUME_ID,		resumeId);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.CITY, 			companyCity);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.STATE,			companyState);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.TITLE,			title);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.START_DATE, 	startDate);
		contentValues.put(KOResumeProviderMetaData.JobsTableMetaData.END_DATE, 		endDate);
	
		ContentResolver contentResolver = mContext.getContentResolver();
		Uri uri = KOResumeProviderMetaData.JobsTableMetaData.CONTENT_URI;
		Uri insertedUri = contentResolver.insert(uri, contentValues);
		
		return Integer.parseInt(insertedUri.getPathSegments().get(1));		
	}
	
	private void insertTestEducation(int resumeId) {
		insertOneEducation(resumeId, 1, "University of Missouri", 		"Columbia",		"MO", "BA, Business", 				Date.parse("6/1/1972"));
		insertOneEducation(resumeId, 2, "San Diego State University", 	"San Diego",	"CA", "MBA, Information Systems",	Date.parse("6/1/1978"));
		insertOneEducation(resumeId, 3, "Certified Scrum Master (CSM)", "San Francisco","CA", null, Date.parse("1/1/2009"));
		insertOneEducation(resumeId, 4, "Sun Certified Java Programmer (SCJP)", 
																		"San francisco","CA", null, Date.parse("4/1/2009"));
	}
	
	private void insertTestJobsAndAccomplishments(int resumeId) {
		insertAppiction(resumeId);
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
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.NAME, 			"Kevin O\'Mara");
		contentValues.put(KOResumeProviderMetaData.ResumeTableMetaData.SUMMARY,			summaryText);
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
}
