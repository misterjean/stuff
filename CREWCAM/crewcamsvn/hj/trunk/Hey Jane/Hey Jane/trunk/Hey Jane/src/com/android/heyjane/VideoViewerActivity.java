package com.android.heyjane;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

import android.app.ListActivity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiManager.MulticastLock;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.Toast;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.io.IOManager;
import com.android.heyjane.io.OnVideoReceivedListener;
import com.android.heyjane.io.receive.HeartbeatSender;
import com.android.heyjane.io.receive.RecievingFileProgress;
import com.android.heyjane.io.receive.TCPReceiver;
import com.android.heyjane.io.receive.UDPReceiver;
import com.android.heyjane.media.RecordableCamera;
import com.android.heyjane.videoviewer.VideoInfo;
import com.android.heyjane.videoviewer.VideoInfoItemSorter;


public class VideoViewerActivity extends ListActivity implements OnClickListener, OnVideoReceivedListener {

	public static ArrayList<VideoInfo> videoInfoList = new ArrayList<VideoInfo>();
	public static VideoInfo selectedVideo;

	ImageButton recordVideoButton;	

	VideoArrayAdapter videoList;

	NotificationManager notificationManager;

	@Override
	public void onDestroy()
	{
		super.onDestroy();	
		IOManager.clearOnVideoReceivedListener(this);
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.videoviewer);       

		Intent splashPageIntent = new Intent(this, SplashActivity.class);
		VideoViewerActivity.this.startActivity(splashPageIntent);

		initializeList();

		initializeButtons();
		
		if (!IOManager.getInstance().tryToInitialize(this))
			finish();
		
		IOManager.getInstance().setOnVideoReceivedListner(this);
	}	

	private void initializeList() {
		videoList = new VideoArrayAdapter(this, videoInfoList, getListView());                     

		setListAdapter(videoList);
	}

	

	@Override
	public void onResume()
	{
		super.onResume();
		try {
			refreshVideoList(VideoInfo.VIDEO_LOCATION);
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}

	public void onClick(View v) { 
		if(v == recordVideoButton)
		{
			Intent videoPlayerIntent = new Intent(this, MediaActivity.class);
			this.startActivity(videoPlayerIntent);
		}
	}

	public void refreshVideoList(String dir)
	{
		File[] videos = new File(dir).listFiles();
		String videoPath = null; 
		Boolean needToUpdate = false;
		Boolean isVideoAlreadyStored = false;

		// Iterate through all our current videos, and see if they still exist        
		for(int currentVideo = 0; currentVideo < videoInfoList.size(); currentVideo++)
		{
			// Does the video still exist?  Otherwise remove it and continue
			if (!videoInfoList.get(currentVideo).videoFile.exists() || !videoInfoList.get(currentVideo).videoFile.exists())
			{    				
				videoInfoList.remove(currentVideo);
				needToUpdate = true;
			}
		}		

		for(int newVideoFile = 0; newVideoFile < videos.length; newVideoFile++)
		{        	
			isVideoAlreadyStored = false;

			// Is this a video file?
			if (!videos[newVideoFile].getAbsoluteFile().getName().contains(VideoInfo.VIDEO_EXTENSION))
				continue;

			// Iterate through all our current videos, and see if they match this one
			for(int currentVideo = 0; currentVideo < videoInfoList.size(); currentVideo++)
			{    			    			
				if (videoInfoList.get(currentVideo).videoFile.getAbsolutePath().equals(videos[newVideoFile].getAbsolutePath()))
				{
					// We already have this video in the array
					isVideoAlreadyStored = true;
					break;
				}    							    							
			}    

			// Did we find a match?
			if (isVideoAlreadyStored)
				continue;

			// We need to add this video to the array list, and refresh it
			needToUpdate = true;

			// Find the videoInfo file path
			videoPath = videos[newVideoFile].getAbsolutePath();    			
			String videoInfoPath = videoPath.substring(0, videoPath.indexOf(".")) + VideoInfo.VIDEO_INFO_EXTENSION;

			File videoInfoFile = new File(videoInfoPath);

			// Is there a videoInfoFile?
			if (!videoInfoFile.exists())
				continue;

			// All good, lets initialize the information and add the video to the list
			try 
			{
				VideoInfo newVideoInfo = new VideoInfo(videoInfoFile);
				
				newVideoInfo.getThumbnail(false);
				
				videoInfoList.add(0, newVideoInfo);

			} catch (Exception e) {
				e.printStackTrace();
			}	    	
		}

		if (needToUpdate) 
		{
			sortAndRefreshList();
		}
	}

	private void sortAndRefreshList() {
		Collections.sort(videoInfoList, new VideoInfoItemSorter());
		videoList.notifyDataSetChanged();
	}

	private void initializeButtons() 
	{		
		recordVideoButton = (ImageButton)findViewById(R.id.recordVideoButton);        
		recordVideoButton.setOnClickListener(this);
	}
	
	public void forceRefreshVideoList() 
	{
		sortAndRefreshList();	
	}

	@Override
	public void onVideoReceived(VideoInfo newVideoInfo) 
	{			
		if (VideoInfo.arrayHasDuplicate(videoInfoList, newVideoInfo))
			return;
		
		Toast.makeText(this, "Video received from " + newVideoInfo.metadata.owner + "!", 3000).show();
		
		videoInfoList.add(0, newVideoInfo);		
		sortAndRefreshList();
	}

}


