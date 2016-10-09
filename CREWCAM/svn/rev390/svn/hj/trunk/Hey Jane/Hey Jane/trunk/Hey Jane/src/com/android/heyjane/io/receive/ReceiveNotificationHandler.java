package com.android.heyjane.io.receive;

import com.android.heyjane.videoviewer.VideoInfo;

import android.content.Context;

public interface ReceiveNotificationHandler
{
	public void onVideoReceived(VideoInfo videoInfo);
	public void onError(String errorMessage);
	public void onStartVideoReception(VideoInfo videoInfo);
}
