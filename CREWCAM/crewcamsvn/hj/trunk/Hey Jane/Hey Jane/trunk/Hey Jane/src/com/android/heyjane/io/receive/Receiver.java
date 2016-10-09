package com.android.heyjane.io.receive;

import android.os.AsyncTask;

public abstract class Receiver extends AsyncTask <Void, RecievingFileProgress, Void>
{
	private ReceiveNotificationHandler notificationHandler;
	protected RTPDecoder decoder;
	boolean haveSeenVideoAlready = false;	// For firing the onStartVideoReception event only once
	
	public Receiver(ReceiveNotificationHandler videoViewerActivity) {
		decoder = new RTPDecoder(new PacketProcessor());	
		this.notificationHandler = videoViewerActivity;
	}


	@Override
	protected void onProgressUpdate(RecievingFileProgress... newVideo) 
	{				
		
		if(receivingFileHasError(newVideo))
		{			
			System.out.println("Error was true.");
			if (newVideo[0].error == true)
			{		
				notificationHandler.onError("Aww, there was an error receiving a video: " + newVideo[0].errorString);
			}								
		}		
		else if (newVideo[0].isVideoComplete != true)
		{
			// Have we already notified everyone that we're receiving a video?
			if (haveSeenVideoAlready)
				return;
			
			// We're receiving a file, but we haven't received it yet!
			notificationHandler.onStartVideoReception(newVideo[0].videoInfo);
			
			haveSeenVideoAlready = true;
		} 	
		else
		{		
			// Generate the thumbnail before we get back to the GUI thread
			
			if (newVideo[0].videoInfo.getThumbnail(true) == null)
			{
				// This video was corrupted.  Delete it, and fire a notification
				System.out.println("Unable to generate thumbnail for " + newVideo[0].videoInfo.videoFile + ".  Size was " + newVideo[0].videoInfo.videoFile.getTotalSpace());
				newVideo[0].videoInfo.videoFile.delete();
				newVideo[0].videoInfo.videoInfoFile.delete();
				notificationHandler.onError("Video from " + newVideo[0].videoInfo.metadata.owner + " was not correctly received");
			}
			else
				notificationHandler.onVideoReceived(newVideo[0].videoInfo);
			
			haveSeenVideoAlready = false;
		}
    }


	private boolean receivingFileHasError(RecievingFileProgress... newVideo) 
	{
		return newVideo[0] == null || newVideo[0].error == true;
	}


}
