package com.kevingomara.utils;

import com.kevingomara.koresume.R;


import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;

public class GenericManagedAlertDialog extends ManagedActivityDialog {

	private String mAlertMessage = null;
	private Context mContext	= null;
	
	public GenericManagedAlertDialog(ManagedDialogsActivity inActivity, int dialogId, String initialMessage) {
		super(inActivity, dialogId);
		
		mAlertMessage 	= initialMessage;
		mContext		= inActivity;
	}
	
	public Dialog create() {
		AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
		builder.setTitle(R.string.alertTitle);
		builder.setMessage(mAlertMessage);
		builder.setPositiveButton(R.string.ok, this);
		AlertDialog alertDialog = builder.create();
		
		return (Dialog) alertDialog;
	}
	
	public void prepare(Dialog dialog) {
		AlertDialog alertDialog = (AlertDialog)dialog;
		alertDialog.setMessage(mAlertMessage);
	}
	
	public void setAlertMessage(String inAlertMessage) {
		mAlertMessage = inAlertMessage;
	}
	
	public void onClickHook(int buttonId) {
		// This method must be overriden
	}
}
