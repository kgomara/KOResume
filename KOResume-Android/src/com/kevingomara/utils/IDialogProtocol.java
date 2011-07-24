package com.kevingomara.utils;

import android.app.Dialog;

public interface IDialogProtocol {
	public Dialog create();
	public int getDialogId();
	public void onClickHook(int buttonId);
	public void prepare(Dialog dialog);
	public void show();
}
