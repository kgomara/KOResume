package com.kevingomara.utils;


import android.content.DialogInterface;

public abstract class ManagedActivityDialog implements IDialogProtocol, android.content.DialogInterface.OnClickListener {

	private ManagedDialogsActivity mActivity = null;
	private int mDialogId = 0;
	
	public ManagedActivityDialog(ManagedDialogsActivity mda, int dialogId) {
		mActivity = mda;
		mDialogId = dialogId;
	}
	
	public int getDialogId() {
		return mDialogId;
	}
	
	public void show() {
		mActivity.showDialog(mDialogId);
	}
	
	public void onClick(DialogInterface v, int buttonId) {
		onClickHook(buttonId);
		this.mActivity.dialogFinished(this, buttonId);
	}
}
