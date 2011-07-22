package com.kevingomara.koresume;

import android.provider.BaseColumns;

public interface KOResumeBaseColumns extends BaseColumns {
	public static final String 	CONTENT_TYPE 		= "vnd.android.cursor.dir/vnd.kevingomara.koresume";
	public static final String 	CONTENT_ITEM_TYPE 	= "vnd.android.cursor.item/vnd.kevingomara.koresume";

	// column name
	public static final String	CREATED_DATE		= "createdDate";

}
