package com.kevingomara.koresume;

import android.net.Uri;
import android.provider.BaseColumns;

public class KOResumeProviderMetaData {
	
	public static final String 	AUTHORITY 			= "com.kevingomara.provider.resumeprovider";
	
	public static final String 	DATABASE_NAME 		= "koresume.db";
	public static final int 	DATABASE_VERSION 	= 1;
	public static final String 	PACKAGE_TABLE_NAME 	= "packages";
	public static final String	RESUME_TABLE_NAME	= "resumes";
	// All tables should use this constant for their CREATED_DATE column name
	public static final String	CREATED_DATE		= "createdDate";
	
	private KOResumeProviderMetaData() {
		// Private to prevent instantiation
	}
	
	public static final class PackageTableMetaData implements BaseColumns {
		private PackageTableMetaData() {
			
		}
		
		public static final String	TABLE_NAME			= PACKAGE_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
		public static final String 	CONTENT_TYPE 		= "vnd.android.cursor.dir/vnd.kevingomara.koresume";
		public static final String 	CONTENT_ITEM_TYPE 	= "vnd.android.cursor.item/vnd.kevingomara.koresume";
		
		// Columns start here
		// String type
		public static final String PACKAGE_NAME 		= "name";
		
		// String type
		public static final String COVER_LTR			= "coverLtr";
		
		// Integer from System.currentTimeMillis()
		public static final String CREATED_DATE 		= KOResumeProviderMetaData.CREATED_DATE;
		
		// Integer type
		public static final String RESUME_ID			= "resumeId";

		public static final String DEFAULT_SORT_ORDER	= CREATED_DATE + " DESC";
}
	
	public static final class ResumeTableMetaData implements BaseColumns {
		private ResumeTableMetaData() {
			
		}
		
		public static final String	TABLE_NAME			= RESUME_TABLE_NAME;
		
		// Uri and MIME type definitions
		public static final Uri 	CONTENT_URI 		= Uri.parse("content://" + AUTHORITY + "/" + TABLE_NAME);
		public static final String 	CONTENT_TYPE 		= "vnd.android.cursor.dir/vnd.kevingomara.koresume";
		public static final String 	CONTENT_ITEM_TYPE 	= "vnd.android.cursor.item/vnd.kevingomara.koresume";
				
		// Columns start here
		// String type
		public static final String RESUME_NAME 			= "name";
		
		// String type
		public static final String SUMMARY_TEXT			= "summary";
		
		// Integer from System.currentTimeMillis()
		public static final String CREATED_DATE 		= KOResumeProviderMetaData.CREATED_DATE;
		
		// Integer type
		public static final String PACKAGE_ID			= "packageId";				// Foreign key
		
		// String type
		public static final String STREET1				= "street1";
		
		// String type
		public static final String STREET2				= "street2";
		
		// String type
		public static final String CITY					= "city";
		
		// String type
		public static final String STATE				= "state";
		
		// String type
		public static final String POSTAL_CODE			= "postal";
		
		// String type
		public static final String HOME_PHONE			= "homePhone";
		
		// String type
		public static final String MOBILE_PHONE			= "mobilePhone";
		
		public static final String DEFAULT_SORT_ORDER	= CREATED_DATE + " DESC";
	}
}
