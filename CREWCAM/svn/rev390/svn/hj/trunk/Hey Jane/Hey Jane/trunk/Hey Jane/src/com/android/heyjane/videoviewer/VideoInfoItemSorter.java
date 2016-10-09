package com.android.heyjane.videoviewer;

import java.util.Comparator;

public class VideoInfoItemSorter implements Comparator<VideoInfo> {
	@Override
	public int compare(VideoInfo videoOne, VideoInfo videoTwo)
	{
		// leading subtraction makes it show things in terms of "newest" first
		return -videoOne.timeStamp.compareTo(videoTwo.timeStamp);
	}

}
