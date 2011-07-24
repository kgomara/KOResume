package com.kevingomara.utils;

import com.kevingomara.koresume.R;


import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

public class GenericPromptDialog extends ManagedActivityDialog {

//	private String mPromptMessage	= null;
	private View mPromptView		= null;
	String mPromptValue				= null;
	private Context mContext		= null;
	
	public GenericPromptDialog(ManagedDialogsActivity activity, int dialogId, String promptMessage) {
		super(activity, dialogId);
		
//		mPromptMessage	= promptMessage;
		mContext		= activity;
	}
	
	@Override
	public Dialog create() {
		LayoutInflater layoutInflater = LayoutInflater.from(mContext);
		// TODO refactor to pass in resource id for layout
		mPromptView = layoutInflater.inflate(R.layout.package_prompt, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
		builder.setTitle(R.string.promptTitle);
		builder.setView(mPromptView);
		builder.setPositiveButton(R.string.ok, this);
		builder.setNegativeButton(R.string.cancel, this);
		AlertDialog alertDialog = builder.create();
		
		return alertDialog;
	}
	
	@Override
	public void onClickHook(int buttonId) {
		if (buttonId == DialogInterface.BUTTON1) {
			EditText editText = (EditText) mPromptView.findViewById(R.id.editPackageName);
			mPromptValue = editText.getText().toString();
		}
	}
	
	@Override
	public void prepare(Dialog dialog) {
		// This method must be overriden
	}
}
