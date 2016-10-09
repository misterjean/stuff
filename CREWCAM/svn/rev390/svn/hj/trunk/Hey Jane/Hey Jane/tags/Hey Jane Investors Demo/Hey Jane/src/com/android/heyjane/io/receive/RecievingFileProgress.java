package com.android.heyjane.io.receive;

import com.android.heyjane.videoviewer.VideoInfo;

public class RecievingFileProgress
{
	public VideoInfo videoInfo = null;
	public float percentLost;
	public Boolean error = false;
	public String errorString;
	public boolean isVideoComplete = false;
}
