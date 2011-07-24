package com.kevingomara.utils;


import android.content.DialogInterface;

public abstract class ManagedActivityDialog implements IDialogProtocol, android.content.DialogInterface.OnClickListener {

	private ManagedDialogsActivity mActivity = null;
	private int mDialogId = 0;
	
	public ManagedActivityDialog(ManagedDialogsActivity mda, int dialogId) {
		mActivity = mda;
		mDialogId = dialogId;
	}
	
	@Override
	public int getDialogId() {
		return mDialogId;
	}
	
	@Override
	public void onClick(DialogInterface v, int buttonId) {
		onClickHook(buttonId);
		this.mActivity.dialogFinished(this, buttonId);
	}
	
	@Override
	public void show() {
		mActivity.showDialog(mDialogId);
	}
}
