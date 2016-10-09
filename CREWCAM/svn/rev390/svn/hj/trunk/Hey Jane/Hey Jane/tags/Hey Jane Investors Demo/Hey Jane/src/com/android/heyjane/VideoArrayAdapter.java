package com.android.heyjane;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.videoviewer.VideoInfo;

public class VideoArrayAdapter extends ArrayAdapter<VideoInfo> implements OnItemClickListener, OnClickListener {

	private final VideoViewerActivity context;
	private final ArrayList<VideoInfo> videoArray;
	private View lastSelectedVideoView;
	private int lastSelectedVideoId;
	
	public VideoArrayAdapter(VideoViewerActivity context, ArrayList<VideoInfo> videoArray, ListView listView) {
		
		super(context, R.layout.videorow, videoArray);
		this.context = context;
		this.videoArray = videoArray;
		if (listView != null)
			listView.setOnItemClickListener(this);		
	}

	@Override
	public View getView(int position, View currentView, ViewGroup parent) {
	
		ViewHolder cachedViews;
		VideoInfo currentVideo = (VideoInfo)videoArray.get(position);
		
		if (currentView == null)
		{
			// Inflate the row, and get all the views
			LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			currentView = inflater.inflate(R.layout.videorow, parent, false);
			cachedViews = new ViewHolder();
			
			cachedViews.liketext = (TextView) currentView.findViewById(R.id.liketext);
			cachedViews.ownerThumb = (ImageView) currentView.findViewById(R.id.UserImage);
			cachedViews.timeSinceCreation = (TextView) currentView.findViewById(R.id.timeSinceCreation);
			cachedViews.videoOwner = (TextView) currentView.findViewById(R.id.UserName);
			cachedViews.videoThumb = (ImageView) currentView.findViewById(R.id.videoThumb);
			cachedViews.tagsLayout = (LinearLayout)currentView.findViewById(R.id.tags);	
			
			currentVideo.videoPlay = (ImageButton)currentView.findViewById(R.id.videoPlay);
			currentVideo.videoPlay.setOnClickListener(this);
			currentVideo.videoSend = (ImageButton)currentView.findViewById(R.id.videoSend);
			currentVideo.videoSend.setOnClickListener(this);
			currentVideo.videoDelete = (ImageButton)currentView.findViewById(R.id.videoDelete);
			currentVideo.videoDelete.setOnClickListener(this);
			
			currentView.setTag(cachedViews);				
		}
		else
		{
			// Just get the cached views
			cachedViews = (ViewHolder)currentView.getTag();
		}
		
		// Generate the buttons for each tag
		cachedViews.tagsLayout.removeAllViews();		// Remove the old tags
		Iterator<String> tagsIterator = currentVideo.getTags().iterator();
		while(tagsIterator.hasNext())
		{				
			cachedViews.tagsLayout.addView(generateTagButton(tagsIterator.next(), cachedViews.tagsLayout.getContext()));		
		}				
		
		cachedViews.videoOwner.setText(currentVideo.metadata.owner);		
		cachedViews.liketext.setText(currentVideo.metadata.getNumberOfLikes() + " likes");
		
		long ageOfVideoMilliseconds = new Date().getTime() - currentVideo.timeStamp.getTime();
		long ageOfVideoSeconds = ageOfVideoMilliseconds/1000;
		long ageOfVideoMinutes = ageOfVideoMilliseconds/60000;
		if (ageOfVideoSeconds < 60)
		{
			cachedViews.timeSinceCreation.setText("just now");
		}
		else if(ageOfVideoSeconds >= 60 && ageOfVideoMinutes < 60)
		{
			cachedViews.timeSinceCreation.setText("about "+ageOfVideoMinutes+" minutes ago");
		}
		else if(ageOfVideoMinutes >= 60 && ageOfVideoMinutes < (24*60))
		{
			cachedViews.timeSinceCreation.setText("about "+ageOfVideoMinutes/60+" hours ago");
		}
		else
		{
			cachedViews.timeSinceCreation.setText("about "+ageOfVideoMinutes/(24*60)+" days ago");
		}		
		
		cachedViews.videoThumb.setImageBitmap(currentVideo.getThumbnail(false));
		cachedViews.ownerThumb.setImageResource(VideoInfo.getUserDrawable(currentVideo));
		
		// Always clear the selection when we're working with an old view
		if (((LinearLayout)currentView.findViewById(R.id.videoActions)).getVisibility() == LinearLayout.VISIBLE)
			((LinearLayout)currentView.findViewById(R.id.videoActions)).setVisibility(LinearLayout.GONE);

		return currentView;		
	}
    static class ViewHolder {
		TextView videoOwner;
		ImageView videoThumb;
		ImageView ownerThumb;
		TextView liketext;
		TextView timeSinceCreation;
		LinearLayout tagsLayout;
    }
	
    private Button generateTagButton(String text, Context context) {
    	Button tagsButton = new Button(context);
		tagsButton.setText(text);
		tagsButton.setTextSize(10);		
		tagsButton.setHeight(25);
		tagsButton.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, 60));
		tagsButton.setOnClickListener(this);
		tagsButton.setId(R.id.tagsButton);
		return tagsButton;
	}

	@Override
	public void onItemClick(AdapterView<?> adaterView, View v, int viewPosition,
			long viewID) 
	{		
		if (lastSelectedVideoView != null)
		{
			// Hide the last selected video
			((LinearLayout)lastSelectedVideoView.findViewById(R.id.videoActions)).setVisibility(LinearLayout.GONE);
			((RelativeLayout)lastSelectedVideoView.findViewById(R.id.videoOverlay)).setVisibility(RelativeLayout.GONE);
		}
		
		if (lastSelectedVideoView == v)
		{
			// Just hide the last selected video
			lastSelectedVideoView = null;
			return;	
		}
		
		// Save this video's information.  Next time we get an onClick event for one of the 
		// video actions, we'll use this information to know which video to use
		lastSelectedVideoView = v;
		lastSelectedVideoId = viewPosition;
		
		LinearLayout videoActions = (LinearLayout)v.findViewById(R.id.videoActions);
		RelativeLayout videoOverlay = (RelativeLayout)v.findViewById(R.id.videoOverlay);
		
		// Show the video's actions
		videoActions.setVisibility(LinearLayout.VISIBLE);
		videoOverlay.setVisibility(RelativeLayout.VISIBLE);
	}


	@Override
	public void onClick(View v) 
	{
		switch (v.getId())
		{
		case R.id.videoPlay:
			playSelectedVideo(videoArray.get(lastSelectedVideoId));
			break;
		case R.id.videoSend:
			sendSelectedVideo(videoArray.get(lastSelectedVideoId));	
			break;
		case R.id.videoDelete:
			deleteSelectedVideo(lastSelectedVideoId);
			break;
		case R.id.tagsButton:
			showTagsView((Button)v);
		}	
	}

	private void showTagsView(Button tagsButton) 
	{
		// Although it probably not the best way, for now we just pull the String off the button's "Text"
		String tagsToShow = (String) tagsButton.getText();
		
		// Start the feed viewer, passing it the tags to look for
		Intent VideoViewerIntent = new Intent(context, VideoFeedActivity.class);
		VideoViewerIntent.putExtra("TAG_TO_VIEW", tagsToShow);
		context.startActivity(VideoViewerIntent);		
	}


	private void sendSelectedVideo(VideoInfo video) 
	{	
		try {
			ConfigurationManager.getTransmitter().SendFile(video, context);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	private void playSelectedVideo(VideoInfo video) {
		Intent MediaActivityIntent = new Intent(context, MediaActivity.class);
		MediaActivityIntent.putExtra("videoFile", video.videoFileLocation);
		context.startActivity(MediaActivityIntent);
	}

	private void deleteSelectedVideo(int videoID) 
	{
		if(!videoArray.get(videoID).videoInfoFile.delete() || !videoArray.get(videoID).videoFile.delete())
		{
			Toast.makeText(context, "Error: Deleting file", 2000).show();
		}
		else
		{
			if (videoArray.get(videoID).getThumbnail(true) != null)
				videoArray.get(videoID).getThumbnail(true).recycle();
			
			// Remove the element
			videoArray.remove(videoID);						
			
			// Force the listView to refresh
			context.forceRefreshVideoList();
		}
	}

}
