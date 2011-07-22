package com.kevingomara.koresume;

import android.net.Uri;
import android.provider.BaseColumns;

public class KOResumeProviderMetaData {
	
	public static final String 	AUTHORITY 					= "com.kevingomara.provider.resumeprovider";
	
	public static final String 	DATABASE_NAME 				= "koresume.db";
	public static final int 	DATABASE_VERSION 			= 1;
	public static final String 	PACKAGE_TABLE_NAME 			= "packages";
	public static final String	RESUME_TABLE_NAME			= "resumes";
	public static final String	JOBS_TABLE_NAME				= "jobs";
	public static final String	ACCOMPLISHMENTS_TABLE_NAME	= "accomplishments";
	public static final String	EDUCATION_TABLE_NAME		= "education";
	// All tables should use this constant for their CREATED_DATE column name
	
	private KOResumeProviderMetaData() {
		// Private to prevent instantiation
	}
	
	public static final class PackageTableMetaData implements KOResumeBaseColumns {
		private PackageTableMetaData() {
			// Private to prevent instantiation			
		}
		
		public static final String	TABLE_NAME			= PACKAGE_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
		
		// Columns start here
		public static final String	NAME 				= "name";			// String type	
		public static final String	COVER_LTR			= "coverLtr";		// String type
		public static final String	RESUME_ID			= "resumeId";		// Integer type

		public static final String	DEFAULT_SORT_ORDER	= CREATED_DATE + " DESC";
}
	
	public static final class ResumeTableMetaData implements KOResumeBaseColumns {
		private ResumeTableMetaData() {
			// Private to prevent instantiation			
		}
		
		public static final String	TABLE_NAME			= RESUME_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
				
		// Columns start here
		public static final String	NAME 				= "name";			// String type
		public static final String	SUMMARY				= "summary";		// String type
		public static final String	PACKAGE_ID			= "packageId";		// Integer type, Foreign key
		public static final String	STREET1				= "street1";		// String type
		public static final String	STREET2				= "street2";		// String type
		public static final String	CITY				= "city";			// String type
		public static final String	STATE				= "state";			// String type
		public static final String	POSTAL_CODE			= "postal";			// String type
		public static final String	HOME_PHONE			= "homePhone";		// String type
		public static final String	MOBILE_PHONE		= "mobilePhone";	// String type
		
		public static final String	DEFAULT_SORT_ORDER	= CREATED_DATE + " DESC";
	}
	
	public static final class JobsTableMetaData implements KOResumeBaseColumns {
		private JobsTableMetaData() {
			// Private to prevent instantiation			
		}
		
		public static final String	TABLE_NAME			= JOBS_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
				
		// Columns start here
		public static final String	NAME 				= "name";		// String type
		public static final String	SUMMARY				= "summary";	// String type
		public static final String	RESUME_ID			= "resumeId";	// Integer type, Foreign key
		public static final String	URI 				= "uri";		// String type
		public static final String	TITLE				= "title";		// String type
		public static final String	START_DATE			= "startDate";	// Integer from System.currentTimeMillis()
		public static final String	END_DATE			= "endDate";	// Integer from System.currentTimeMillis()
		public static final String	CITY				= "city";		// String type
		public static final String	STATE				= "state";		// String type
		
		public static final String	DEFAULT_SORT_ORDER	= START_DATE + " DESC";
	}
	
	public static final class AccomplishmentsTableMetaData implements KOResumeBaseColumns {
		private AccomplishmentsTableMetaData() {
			// Private to prevent instantiation			
		}
		
		public static final String	TABLE_NAME			= ACCOMPLISHMENTS_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
				
		// Columns start here
		public static final String	NAME 				= "name";		// String type
		public static final String	SUMMARY 			= "summary";	// String type
		public static final String	JOBS_ID				= "jobsId";		// Integer type, Foreign key
		public static final String	SEQUENCE_NUMBER		= "sequence";	// Integer type
		
		public static final String	DEFAULT_SORT_ORDER	= SEQUENCE_NUMBER + " ASC";
	}
	
	public static final class EducationTableMetaData implements KOResumeBaseColumns {
		private EducationTableMetaData() {
			// Private to prevent instantiation			
		}
		
		public static final String	TABLE_NAME			= EDUCATION_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
				
		// Columns start here
		public static final String	NAME		 		= "name";		// String type
		public static final String	RESUME_ID			= "resumeId";	// Integer type, Foreign key
		public static final String	TITLE				= "title";		// String type
		public static final String	CITY				= "city";		// String type
		public static final String	STATE				= "state";		// String type
		public static final String	SEQUENCE_NUMBER		= "sequence";	// Integer type
		public static final String	EARNED_DATE			= "endDate";	// Integer from System.currentTimeMillis()
		
		public static final String	DEFAULT_SORT_ORDER	= SEQUENCE_NUMBER + " ASC";
	}
}
