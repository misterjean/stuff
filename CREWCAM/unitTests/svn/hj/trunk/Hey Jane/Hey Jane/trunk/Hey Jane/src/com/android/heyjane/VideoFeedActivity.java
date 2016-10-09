package com.android.heyjane;


import java.util.ArrayList;
import java.util.Collections;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.PixelFormat;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.media.MediaPlayer.OnVideoSizeChangedListener;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.TranslateAnimation;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.heyjane.customlistview.HorizontialListView;
import com.android.heyjane.io.IOManager;
import com.android.heyjane.io.OnVideoReceivedListener;
import com.android.heyjane.videoviewer.VideoInfo;
import com.android.heyjane.videoviewer.VideoInfoItemSorter;

public class VideoFeedActivity extends Activity implements Callback, OnCompletionListener, OnPreparedListener, OnVideoSizeChangedListener, OnItemSelectedListener, OnVideoReceivedListener, OnTouchListener
{
	ArrayList<VideoInfo> tagVideoInfoList = new ArrayList<VideoInfo>();

	private int currentVideoId = 0;

	SurfaceView surfaceView;
	SurfaceHolder surfaceHolder;
	RelativeLayout videoFeedInfoContainer;

	TextView videoTitle;
	TextView videoOwner;
	TextView tagText;

	private String tagTextString = "";

	private int videoWidth;
	private int videoHeight;
	private boolean isVideoReady;
	private boolean isVideoSizeKnown;
	private MediaPlayer mediaPlayer = new MediaPlayer();

	private HorizontialListView listview;

	private boolean isVideoFeedShowing = true;
	private boolean wasScreenTouched = false;

	private BaseAdapter listAdapter = new BaseAdapter(){  

		@Override  
		public int getCount() {  
			return tagVideoInfoList.size();  
		}  

		@Override  
		public Object getItem(int position) {  
			return null;  
		}  

		@Override  
		public long getItemId(int position) {  
			return 0;  
		}  

		@Override  
		public View getView(int position, View convertView, ViewGroup parent) 
		{
			if (convertView == null)
			{
				LayoutInflater inflater = (LayoutInflater) parent.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.videofeedlistitem, parent, false);		
			}
			
			ImageView videoThumb = (ImageView) convertView.findViewById(R.id.videoListThumb);
			
			videoThumb.setImageBitmap(tagVideoInfoList.get(position).getThumbnail(false));

			return convertView;  
		}

	};	

	void refreshVideos(String tag)
	{	
		for (int currentVideo = 0; currentVideo < VideoViewerActivity.videoInfoList.size(); currentVideo++)
		{
			if (videoContainsTag(tag, VideoViewerActivity.videoInfoList.get(currentVideo)) && !tagVideoInfoList.contains(VideoViewerActivity.videoInfoList.get(currentVideo)))			
				tagVideoInfoList.add(VideoViewerActivity.videoInfoList.get(currentVideo));
		}
		
		Collections.sort(tagVideoInfoList, new VideoInfoItemSorter());
	}

	// Iterates through the tags in the video, and checks if they are equal to the given string
	private Boolean videoContainsTag(String tag, VideoInfo currentVideo) 
	{
		for(int currentTag = 0; currentTag < currentVideo.getTags().size(); currentTag++)
		{
			if (currentVideo.getTags().get(currentTag).equals(tag))
			{
				return true;
			}				
		}

		return false;
	}

	@Override
	public void onDestroy()
	{
		super.onDestroy();	
		IOManager.clearOnVideoReceivedListener(this);
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);

		setContentView(R.layout.videofeed);		

		IOManager.getInstance().setOnVideoReceivedListner(this);

		Bundle extras = getIntent().getExtras();
		if (extras != null)
		{
			String tag = extras.getString("TAG_TO_VIEW");
			if (tag != null)
			{
				refreshVideos(tag);
				tagTextString = tag;
			}
			else
			{
				finish();
			}

		}		

		intializeViews();		
		
		IOManager.getInstance().setOnVideoReceivedListner(this);
	}

	private void intializeViews() {
		getWindow().setFormat(PixelFormat.UNKNOWN);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);

		surfaceView = (SurfaceView)findViewById(R.id.videoFeedSurface);			

		surfaceHolder = surfaceView.getHolder();

		surfaceHolder.addCallback(this);
		surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);	

		listview = (HorizontialListView) findViewById(R.id.videoFeedListView);  
		listview.setOnTouchListener(this);

		listview.setOnItemSelectedListener(this);
		listview.setAdapter(listAdapter); 

		videoFeedInfoContainer = (RelativeLayout)findViewById(R.id.videoFeedInfoContainer);
		videoTitle = (TextView)findViewById(R.id.videoTitleText);
		videoOwner = (TextView)findViewById(R.id.videoOwnerText);
		tagText = (TextView)findViewById(R.id.tagText);
		tagText.setText("\"" + tagTextString + "\"");				
	}		

	private void start() throws Exception
	{
		playVideo(currentVideoId);		
	}

	private void playVideo(int videoId) throws Exception
	{		
		refreshSelectedVideos(videoId);

		mediaPlayer.setDataSource(tagVideoInfoList.get(videoId).videoFileLocation);
		mediaPlayer.setDisplay(surfaceHolder);    	
		mediaPlayer.prepare();
		mediaPlayer.setOnCompletionListener(this);  
		mediaPlayer.setOnPreparedListener(this);
		mediaPlayer.setOnVideoSizeChangedListener(this);
		mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);		

		videoTitle.setText(tagVideoInfoList.get(videoId).name);
		videoOwner.setText("From " + tagVideoInfoList.get(videoId).metadata.owner);		
	}

	private void refreshSelectedVideos(int currentlyPlayingVideo) 
	{
		setVideoSelected(currentlyPlayingVideo);
		for(int currentVideo = 0; currentVideo < tagVideoInfoList.size(); currentVideo++)
		{
			if (currentVideo == currentlyPlayingVideo)
				continue;

			setVideoUnselected(currentVideo);
		}
	} 

	private void setVideoSelected(int videoId) 
	{
		if (listview.getChildAt(videoId) != null)
			listview.getChildAt(videoId).findViewById(R.id.videoListThumb).setBackgroundColor(0xFFFFFFFF);	
	}

	private void setVideoUnselected(int videoId) 
	{
		if (listview.getChildAt(videoId) != null)
			listview.getChildAt(videoId).findViewById(R.id.videoListThumb).setBackgroundColor(0x00000000);		
	}

	private void eventuallyHideVideoFeed()
	{		
		if (!isVideoFeedShowing)
			return;
		// Hide the feed after a couple seconds
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			public void run() {
				if (wasScreenTouched)
				{
					wasScreenTouched = false;
					eventuallyHideVideoFeed();
					return;
				}

				hideVideoFeed();
			}			
		},2000);

	}

	private void hideVideoFeed() {
		if (!isVideoFeedShowing)
			return;

		TranslateAnimation test = new TranslateAnimation(0, 0, 0, videoFeedInfoContainer.getHeight());
		test.setDuration(1000);
		test.setFillAfter(true);
		videoFeedInfoContainer.startAnimation(test);

		isVideoFeedShowing = false;
	}

	private void showVideoFeed() {		
		if (isVideoFeedShowing)
			return;

		TranslateAnimation test = new TranslateAnimation(0, 0, videoFeedInfoContainer.getHeight(), 0);
		test.setDuration(200);
		test.setFillAfter(true);
		videoFeedInfoContainer.startAnimation(test);

		isVideoFeedShowing = true;
		wasScreenTouched = false;
		eventuallyHideVideoFeed();	// Start waiting to hide it again
	}

	public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
		if (width == 0 || height == 0) {
			return;
		}

		isVideoSizeKnown = true;
		videoWidth = width;
		videoHeight = height;

		if (isVideoReady)
		{
			startVideoPlayback();
		}         
	}

	private void startVideoPlayback() 
	{		
		surfaceHolder.setFixedSize(videoWidth, videoHeight);
		mediaPlayer.start();
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {

	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) 
	{
		try
		{
			start();
			eventuallyHideVideoFeed();
		}
		catch (Exception e)
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("Darn it, there was a problem with the media player: " + e.getMessage())
			.setCancelable(false)
			.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			}).show();

			e.printStackTrace();
		}
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {

	}

	@Override
	public void onPrepared(MediaPlayer mediaPlayer) 
	{		
		isVideoReady = true;

		if (isVideoSizeKnown)
			mediaPlayer.start();				
	}

	@Override
	public void onCompletion(MediaPlayer mp) 
	{
		try
		{
			playNextVideo();
		}
		catch (Exception e)
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("Darn it, there was a problem with the media player: " + e.getMessage())
			.setCancelable(false)
			.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			}).show();

			e.printStackTrace();
		}
	}

	private void playNextVideo() throws Exception 
	{
		if(currentVideoId < tagVideoInfoList.size() - 1)
		{
			currentVideoId++;
		}
		else
		{	
			currentVideoId = 0;
		}

		mediaPlayer.reset();

		processNewVideo();

	}

	private void processNewVideo() throws Exception 
	{
		playVideo(currentVideoId);
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) 
	{		
		wasScreenTouched = true;
		showVideoFeed();
		return v.onTouchEvent(event);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		wasScreenTouched = true;
		showVideoFeed();		 
		return super.onTouchEvent(event);
	}


	@Override
	public void onItemSelected(AdapterView<?> adaterView, View view, int viewPosition,
			long viewID) 
	{		
		currentVideoId = viewPosition;
		mediaPlayer.reset();
		try{
			start();
		} 	 
		catch (Exception e)
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("Darn it, there was a problem with the media player: " + e.getMessage())
			.setCancelable(false)
			.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			}).show();

			e.printStackTrace();
		}
		wasScreenTouched = true;
	}

	@Override
	public void onNothingSelected(AdapterView<?> arg0) {
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			mediaPlayer.reset();
		}
		return super.onKeyDown(keyCode, event);
	}


	public void onVideoReceived(VideoInfo newVideoInfo)
	{
		if (videoContainsTag(tagTextString, newVideoInfo))
		{			
			if (VideoInfo.arrayHasDuplicate(tagVideoInfoList, newVideoInfo))
				return;
			
			tagVideoInfoList.add(newVideoInfo);
			listAdapter.notifyDataSetChanged();

			// Hide the feed after a couple seconds
			Handler handler = new Handler();
			handler.postDelayed(new Runnable() {
				public void run() {
					refreshSelectedVideos(currentVideoId);
					showVideoFeed();
				}			
			},1000);
			
			
		}

	}	
}
