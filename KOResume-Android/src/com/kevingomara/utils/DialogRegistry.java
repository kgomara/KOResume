package com.kevingomara.utils;


import android.app.Dialog;
import android.util.SparseArray;

public class DialogRegistry {
	SparseArray<IDialogProtocol> idsToDialogs = new SparseArray<IDialogProtocol>();
	
	public Dialog create(int id) {
		IDialogProtocol dialogProtocol = idsToDialogs.get(id);
		
		if (dialogProtocol == null) {
			return null;
		}
		
		return dialogProtocol.create();
	}
	
	public void prepare(Dialog dialog, int id) {
		IDialogProtocol dialogProtocol = idsToDialogs.get(id);
		
		if (dialogProtocol == null) {
			throw new RuntimeException("Dialog id is not registered: " + id);
		}
		
		dialogProtocol.prepare(dialog);
	}
	
	public void registerDialog(IDialogProtocol dialog) {
		idsToDialogs.put(dialog.getDialogId(), dialog);
	}
}
