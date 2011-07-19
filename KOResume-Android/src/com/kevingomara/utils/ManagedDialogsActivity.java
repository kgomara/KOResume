package com.kevingomara.utils;


import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;

public class ManagedDialogsActivity extends Activity implements IDialogFinishedCallBack {

	// Registry for managed dialogs
	private DialogRegistry dialogRegistry = new DialogRegistry();
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.registerDialogs();
	}
	
	protected void registerDialogs() {
		// This method must be overriden
	}
	
	public void registerDialog(IDialogProtocol dialog) {
		this.dialogRegistry.registerDialog(dialog);
	}
	
	@Override
	protected Dialog onCreateDialog(int id) {
		return this.dialogRegistry.create(id);
	}
	
	@Override
	protected void onPrepareDialog(int id, Dialog dialog) {
		this.dialogRegistry.prepare(dialog, id);
	}
	
	public void dialogFinished(ManagedActivityDialog dialog, int buttonId) {
		// This method must be overriden
	}
}
