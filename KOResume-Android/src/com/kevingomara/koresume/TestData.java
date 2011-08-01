package com.kevingomara.koresume;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
	
	public TestData(Context context) {
		mContext = context;
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
		String acc1 = "Introduced Scrum (an Agile Methodology) to improve quality and predictability.";
		String acc2 = "Drive on-time delievery of mobile apps implemented in Cocoa/Objective-C (C++) and Java, "
					+ "as well as their supporting websites in Django, Amazon AWS, and Google App Engine.";
		String acc3 = "Sole developer of an iPhone app (Academy2GO), using RESTful interface and JSON to communicate "
					+ "with a backend WebSphere CMS.  The app configured itself based on CMS metadata, maintained a "
					+ "LRU cache cache of content objects, streamed video, and displayed several media types.";
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
	
	private void insertMacys(int resumeId) {
		String resp = "The Western division of Macy’s operated 230 retail stores in the Western US, Hawaii, and Guam. "
					+ "I led the Advertising department’s technology team of 8 and was responsible for automating digital "
					+ "workflow for publishing, photo studio, and prepress operations on Mac and PC computers.";
		String acc1 = "Introduced Scrum and engineering best practices to double productivity and align engineering efforts "
					+ "with business priorities.";
		String acc2 = "Implemented a Podcast site on LoudBlog (Open Source CMS) to deliver engaging videos and entice "
					+ "the Millennial Generation to shop at Macy’s.";
		String acc3 = "Implemented Wiki and CMS Web sites on the Joomla platform to deliver timely, strategic promotional "
					+ "information to the Merchant and Stores organizations.  They used the information to optimize mall "
					+ "and in-store signage, floor merchandising, and training of sales associates.";
		String acc4 = "Established a standardized LAMP (Linux, Apache, MySQL, PHP) Web platform and implemented "
					+ "Virtualization technology to ensure high system availability while reducing costs.  Established and "
					+ "enforced appropriate security policy in collaboration with Division Security Office and integration "
					+ "with corporate Active Directory services.";
		String acc5 = "Established metrics for technical support and SLA for system availability.";
				
		int jobId = insertOneJob(	resumeId,
									"Macy\'s West", 
									"www.macys.com", 
									"San Francisco", "CA", 
									"Director, Advertising Technology", 
									Date.parse("11/06/2006"),
									Date.parse("09/01/2009"),
									resp);
		insertOneAccomplishment(jobId, 1, "Introduced Scrum", 			acc1);
		insertOneAccomplishment(jobId, 2, "Implemented Podcast Site",	acc2);
		insertOneAccomplishment(jobId, 3, "Implemented Wike and CMS",	acc3);
		insertOneAccomplishment(jobId, 4, "Established LAMP Platform",	acc4);
		insertOneAccomplishment(jobId, 5, "Established Best Practices", acc5);
	}
	
	private void insertOCA(int resumeId) {
		String resp = "Provide technology consulting services for clients:";
		String acc1 = "Harcourt Achieve – led the Educational Technology team to develop subscription based Web products on "
					+ "Zend/PHP, J2EE, and .NET platforms utilizing outsourced and off-shore contractors.  Awards: PowerUp "
					+ "– AEP Golden Lamp finalist; Palm eAssessment SIAA “Codie” nominee.";
		String acc2 = "Compass Learning – rebuilt development processes and organization in Austin after company closed "
					+ "San Diego development operations.";
		String acc3 = "Cosmos Literacy – defined XML data integration strategy based on SIF (School Interoperability "
					+ "Framework) that qualified Cosmos’ products for large sales opportunities at the district level.";
		String acc4 = "HOSTS Learning – performed due diligence technology assessment to establish valuation of a .NET "
					+ "product.  Assessed existing J2EE product and developed long term strategic roadmap.  Supported "
					+ "Sales in responses to school district RFPs.";
				
		int jobId = insertOneJob(	resumeId,
									"O\'Mara Consulting Associates", 
									"www.kevingomara.com", 
									"Austin", "TX", 
									"Principal", 
									Date.parse("03/01/2002"),
									Date.parse("10/01/2006"),
									resp);
		insertOneAccomplishment(jobId, 1, "For Harcourt Achieve", 	acc1);
		insertOneAccomplishment(jobId, 2, "For Compass Learning",	acc2);
		insertOneAccomplishment(jobId, 3, "For Cosmos Literacy",	acc3);
		insertOneAccomplishment(jobId, 4, "For Hosts Learning",		acc4);
	}
	
	private void insertLoquendo(int resumeId) {
		String resp = "Loquendo (formerly Vocal Point) developed a Voice Browser enabling consumers to use the telephone to "
					+ "access Web sites.  Loquendo hosted Voice Browser as a service to businesses using the SaaS (Software "
					+ "as a Service) business model.  I developed and managed a team of 40 through 5 Directors (3 Engineering, "
					+ "1 QA, and 1 Customer Service).";
		String acc1 = "Re-architected product line to support enterprise licensing on Windows NT, Linux, and UNIX, creating "
					+ "new sales opportunities.";
		String acc2 = "Developed Java based “VoiceBrowser” utilizing Speech Recognition, Text-to-Speech, and Computer "
					+ "Telephony Integration (CTI).";
		String acc3 = "Established iterative SDLC process and managed development of five releases in two years.";
		String acc4 = "Effectively presented synergistic product vision during due diligence, resulting in acquisition by "
					+ "Telecom Italia in August 2001.";
				
		int jobId = insertOneJob(	resumeId,
									"Loquendo, Inc.", 
									"www.loquendo.com/en", 
									"San Francisco", "CA", 
									"VP Engineering", 
									Date.parse("03/01/2000"),
									Date.parse("02/28/2002"),
									resp);
		insertOneAccomplishment(jobId, 1, "Revamp Product Line", 	acc1);
		insertOneAccomplishment(jobId, 2, "Develop Voice Browser",	acc2);
		insertOneAccomplishment(jobId, 3, "Establish SDLC",			acc3);
		insertOneAccomplishment(jobId, 4, "Role in Acquistion",		acc4);
	}
	
	private void insertPerSe(int resumeId) {
		String resp = "Per-Se Technologies (now McKesson) served the healthcare industry.  I led a business unit that developed "
					+ "ORSOS – a patient scheduling system for hospitals.  ORSOS was installed at hospitals and integrated with "
					+ "other healthcare systems via XML.   I led a team of 45 through 6 Directors (5 Engineering, 1 QA).";
		String acc1 = "Inherited troubled product and organization – turned both around by establishing solid development "
					+ "process and leading team through difficult challenges to fix the product. Managed flawless Y2K transition "
					+ "of date-oriented scheduling product.";
		String acc2 = "Transformed Client/Server legacy product to reliable, scalable n-Tier ASP (pre-cursor to .NET) "
					+ "architecture supporting Oracle or MS SQL Server.  The new version generated $7M incremental revenue on "
					+ "a base of $120M.";
		String acc3 = "Implemented iterative development based on Rational Unified Process (RUP).";
		String acc4 = "Awards – ORSOS won KLAS “Most Improved Product.";
				
		int jobId = insertOneJob(	resumeId,
									"Per-Se Technologies, Inc.", 
									"www.mckesson.com/en-us/McKesson.com", 
									"San Jose", "CA", 
									"VP Product Development", 
									Date.parse("07/01/1998"),
									Date.parse("02/28/2000"),
									resp);
		insertOneAccomplishment(jobId, 1, "Organization Turn-Around", 	acc1);
		insertOneAccomplishment(jobId, 2, "Transformed Product",		acc2);
		insertOneAccomplishment(jobId, 3, "Established RUP",			acc3);
		insertOneAccomplishment(jobId, 4, "Awards",						acc4);
	}
	
	private void insertTenthPlanet(int resumeId) {
		String resp = "Tenth Planet (now Sunburst) was a start-up developing Math and Reading curriculum products for K-6 Education.  "
					+ "The products integrated CD-ROM, print, and Web resources to create powerful learning experiences.  I led a "
					+ "team of 20 through 2 Managers (Graphic Arts and QA) and 4 Engineer direct reports.";
		String acc1 = "Defined and implemented an Internet strategy to reach an emerging K-12 market segment searching for Web "
					+ "products.  The strategy was balanced against reality – most elementary schools had little or no Internet "
					+ "access at that time.";
		String acc2 = "Awards – Tenth Planet Explores Fractions won SIIA Codie.";
		String acc3 = "Participated in due diligence process resulting in acquisition by Sunburst in May 1998.";
				
		int jobId = insertOneJob(	resumeId,
									"Tenth Planet", 
									"commerce.sunburst.com/result.aspx?txtadv=tenth%20planet", 
									"Half Moon Bay", "CA", 
									"VP Product Development", 
									Date.parse("10/01/1994"),
									Date.parse("05/01/1998"),
									resp);
		insertOneAccomplishment(jobId, 1, "Defined Strategy", 	acc1);
		insertOneAccomplishment(jobId, 2, "Awards",				acc2);
		insertOneAccomplishment(jobId, 3, "Role in Acquistion",	acc3);
	}
	
	private void insertApple(int resumeId) {
		String resp = "Led engineering, QA, production, and operations for Software Dispatch, a business unit that sold 3rd party "
					+ "Mac and Windows applications via a virtual store on an encrypted CD.  I led a team of 12 direct reports and "
					+ "managed a 24/7 telesupport contract to provide fulfillment and technical support services.";
		String acc1 = "Negotiated and managed $1 million development, licensing, and fulfillment contracts.";
		String acc2 = "Built a team of 12 from scratch.";
				
		int jobId = insertOneJob(	resumeId,
									"Apple Computer", 
									"www.apple.com", 
									"Cupertino", "CA", 
									"Engineering Manager", 
									Date.parse("04/01/1993"),
									Date.parse("09/01/1994"),
									resp);
		insertOneAccomplishment(jobId, 1, "Led Engineering", 	acc1);
		insertOneAccomplishment(jobId, 2, "Developed Team",		acc2);
	}
	
	private void insertJostens(int resumeId) {
		String resp = "This start-up (formerly Education Systems Corp, now Compass Learning) developed Integrated Learning System "
					+ "(ILS) products for K-12 Education on Apple and PC networked computers.  I managed several teams of 8-20 "
					+ "direct reports for this fast growing company.";
		String acc1 = "Implemented ILS on Apple IIgs, then Macintosh computers.  Sales of products produced for the Apple platform "
					+ "increased from 5% to 60% of JLC sales, while sales went from $9M to $220M.";
		String acc2 = "Awards – Compton’s CD-ROM won SIIA Codie and Time Magazine Product of the Year.";
				
		int jobId = insertOneJob(	resumeId,
									"Jostens Learning Corp", 
									"www.compasslearning.com", 
									"San Diego", "CA", 
									"Director, Development", 
									Date.parse("01/01/1988"),
									Date.parse("03/30/1993"),
									resp);
		insertOneAccomplishment(jobId, 1, "Led Engineering", 	acc1);
		insertOneAccomplishment(jobId, 2, "Awards",				acc2);
	}
	
	private void insertIntrepid(int resumeId) {
		String resp = "Offered contract programming services to clients.";
				
		insertOneJob(	resumeId,
						"Intrepid Software Development, Inc.", 
						null, 
						"San Diego", "CA", 
						"Contract Programmer", 
						Date.parse("11/01/1976"),
						Date.parse("12/30/1987"),
						resp);
	}
	
	private void insertNationalSemiconductor(int resumeId) {
		String resp = "Developed hardware diagnostics programs.";
				
		insertOneJob(	resumeId,
						"National Semiconductor, Corp.", 
						null, 
						"San Diego", "CA", 
						"Sr. Diagnostic Programmer", 
						Date.parse("04/01/1979"),
						Date.parse("07/30/1980"),
						resp);
	}
	
	private void insertNCR(int resumeId) {
		String resp = "Developed Financial Software";
				
		insertOneJob(	resumeId,
						"NCR, Corp.", 
						null, 
						"San Diego", "CA", 
						"Sr. Programmer Analyst", 
						Date.parse("02/01/1977"),
						Date.parse("03/30/1979"),
						resp);
	}
	
	private void insertCalFirst(int resumeId) {
		String resp = "Developed Financial Software";
				
		insertOneJob(	resumeId,
						"California First Bank", 
						null, 
						"San Diego", "CA", 
						"Programmer", 
						Date.parse("05/01/1975"),
						Date.parse("01/30/1977"),
						resp);
	}
	
	private void insertIBM(int resumeId) {
		String resp = "Sales support";
				
		insertOneJob(	resumeId,
						"IBM Corp.", 
						null, 
						"New Orleans", "LA", 
						"Systems Engineer", 
						Date.parse("06/01/1972"),
						Date.parse("04/30/1975"),
						resp);
	}
	
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
		insertMacys(resumeId);
		insertOCA(resumeId);
		insertLoquendo(resumeId);
		insertPerSe(resumeId);
		insertTenthPlanet(resumeId);
		insertApple(resumeId);
		insertJostens(resumeId);
		insertIntrepid(resumeId);
		insertNationalSemiconductor(resumeId);
		insertNCR(resumeId);
		insertCalFirst(resumeId);
		insertIBM(resumeId);
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
