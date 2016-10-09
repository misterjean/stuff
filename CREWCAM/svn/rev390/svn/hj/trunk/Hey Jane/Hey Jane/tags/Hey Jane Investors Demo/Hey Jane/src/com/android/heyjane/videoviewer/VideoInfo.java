package com.android.heyjane.videoviewer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;
import java.util.StringTokenizer;

import android.graphics.Bitmap;
import android.widget.ImageButton;

import com.android.heyjane.R;
import com.android.heyjane.metadata.Metadata;

public class VideoInfo {

	private class ThumbnailGenerator implements Runnable
	{
		private VideoInfo videoInfo;
		
		public ThumbnailGenerator(VideoInfo video)
		{
			videoInfo = video;
		}
		@Override
		public void run() {
			videoInfo.image = VideoImage.getVideoImage(videoFileLocation);
			
		}
		
	}

	public String name;
	public String videoFileLocation;
	public File videoFile;
	public String videoInfoFileLocation;
	public File videoInfoFile;
	public Date timeStamp;
	public String timeStampString;
	private Bitmap image;
	public ImageButton videoPlay;
	public ImageButton videoSend;
	public ImageButton videoDelete;
	public String tagsString = "";
	public Metadata metadata = new Metadata();
	private boolean hasSpawnedThreadtoGenerateThumbnail = false;

	public static String VIDEO_EXTENSION 	 = ".mp4";
	public static String VIDEO_PREFIX	 	 = "hj_";
	public static String VIDEO_INFO_EXTENSION = ".txt";
	public static String VIDEO_LOCATION 		 = "/sdcard/RecordableCamera/";		

	private Boolean tryCreateVideoFiles()
	{
		videoFile = new File(videoFileLocation);

		if (!videoFile.exists())
		{
			try {
				if (!videoFile.createNewFile())
					return false;
			} catch (IOException e) {
				return false;
			}
		}

		videoInfoFile = new File(videoInfoFileLocation);

		if (!videoInfoFile.exists())
		{
			try {
				if (!videoInfoFile.createNewFile())
					return false;
			} catch (IOException e) {
				return false;
			}
		}

		return true;
	}

	public ArrayList<String> getTags()
	{
		StringTokenizer st = new StringTokenizer(tagsString, " ,");
		ArrayList<String> tagsArray = new ArrayList<String>();
		while (st.hasMoreTokens())
		{
			String thisToken = st.nextToken();
			if (!thisToken.equals(" ") && !thisToken.equals(","))
				tagsArray.add(thisToken);			
		}	

		return tagsArray;
	}

	// Parses the given byte array as a string, and looks for OWNER: and the other one
	// Also creates both the.txt and .mp4 files!
	public VideoInfo(byte[] data) throws Exception {

		String videoInfoString = new String(data);
		String videoName = null;
		String videoOwner = null;		
		String videoTags = null;

		StringTokenizer st = new StringTokenizer(videoInfoString, ":\n");

		while (st.hasMoreTokens())
		{
			String thisToken = st.nextToken();
			if (thisToken.equals("NAME"))
				videoName = st.nextToken();

			if (thisToken.equals("OWNER"))
				videoOwner = st.nextToken();

			if (thisToken.equals("TAGS"))
				videoTags = st.nextToken();
		}	

		initializeVideoData(videoOwner, videoName, videoTags);	
	}

	// Creates a VideoInfo object from an EXISTING videoInfoFile
	public VideoInfo(File videoInfoFile) throws Exception 
	{
		char[] videoInfoBuffer = new char[1000];
		FileReader videoInfoStream = new FileReader(videoInfoFile);

		videoInfoStream.read(videoInfoBuffer, 0, 1000);
		videoInfoStream.close();
		StringTokenizer st = new StringTokenizer(new String(videoInfoBuffer), ":\n");

		while (st.hasMoreTokens())
		{
			String thisToken = st.nextToken();
			//TODO Remove video name as it is not used
			if (thisToken.equals("NAME"))
				name = st.nextToken();

			if (thisToken.equals("OWNER"))
				metadata.owner = st.nextToken();

			if (thisToken.equals("TAGS"))
				tagsString = st.nextToken();
		}

		// Initialize the files with the given path
		videoInfoFileLocation = videoInfoFile.getAbsolutePath();
		videoFileLocation = videoInfoFile.getAbsolutePath().substring(0, videoInfoFile.getAbsolutePath().indexOf(".")) + VIDEO_EXTENSION;

		if (!videoFilesExist())
			throw new Exception("Unable to find video file!");		 

		// Parse the timestamp from the filename
		String timestampString = videoInfoFileLocation.substring(videoInfoFileLocation.indexOf("_") + 1, videoInfoFileLocation.length() - 4);
		SimpleDateFormat timeStampFormat = new SimpleDateFormat("yyyyMMddkkmmss", Locale.CANADA);		
		this.timeStamp = timeStampFormat.parse(timestampString);			
	}

	public VideoInfo() throws Exception 
	{
		timeStamp = new Date();
		timeStampString = new SimpleDateFormat("yyyyMMddkkmmss", Locale.CANADA).format(timeStamp);

		videoFileLocation = VIDEO_LOCATION + VIDEO_PREFIX + timeStampString + VIDEO_EXTENSION;
		videoInfoFileLocation = VIDEO_LOCATION + VIDEO_PREFIX + timeStampString + VIDEO_INFO_EXTENSION;

		if (!tryCreateVideoFiles())
			throw new Exception("Unable to create video file!");
	}

	private boolean videoFilesExist() {

		videoFile = new File(videoFileLocation);

		if (!videoFile.exists())
		{
			return false;
		}

		videoInfoFile = new File(videoInfoFileLocation);

		if (!videoInfoFile.exists())
		{
			return false;
		}

		return true;
	}

	private void initializeVideoData(String videoOwner, String videoName, String videoTags) throws Exception 
	{ 
		this.metadata.owner = videoOwner;
		this.name = videoName;
		this.tagsString = videoTags;

		timeStamp = new Date();
		timeStampString = new SimpleDateFormat("yyyyMMddkkmmss").format(timeStamp);

		videoFileLocation = VIDEO_LOCATION + VIDEO_PREFIX + timeStampString + VIDEO_EXTENSION;
		videoInfoFileLocation = VIDEO_LOCATION + VIDEO_PREFIX + timeStampString + VIDEO_INFO_EXTENSION;

		if (!tryCreateVideoFiles())
			throw new Exception("Unable to create video file!");

		writeMetaData();
	}

	public void writeMetaData() throws IOException {
		FileOutputStream infoWriter = new FileOutputStream(videoInfoFile);
		infoWriter.write(("NAME:" + name + "\nOWNER:" + metadata.owner + "\nTAGS:"+ tagsString + "\n").getBytes());		
	}

	public static int getUserDrawable(VideoInfo currentVideo) 
	{
		if (currentVideo.metadata.owner == null)
			return R.drawable.defaultuser;
			
		if (currentVideo.metadata.owner.equals("Desmond"))
			return R.drawable.desmond;
		
		if (currentVideo.metadata.owner.equals("Ryan"))
			return R.drawable.ryan;
		
		if (currentVideo.metadata.owner.equals("Greg")) 
			return R.drawable.greg;
		
		return R.drawable.defaultuser;
	}

	public Bitmap getThumbnail(boolean generateSync) 
	{
		if (image != null)
			return image;
					
		if (!generateSync)
		{
			if (!hasSpawnedThreadtoGenerateThumbnail)
			{
				hasSpawnedThreadtoGenerateThumbnail = true;
				generateThumbnailAsync();			
			}
		}
		else 
		{
			generateThumbnailSync();
		}
		
		return image;
	}

	private void generateThumbnailAsync() 
	{
		new Thread(new ThumbnailGenerator(this)).start();
		
	}
	
	public void generateThumbnailSync() 
	{
		image = VideoImage.getVideoImage(videoFileLocation);
		
	}

	public static boolean arrayHasDuplicate(ArrayList<VideoInfo> tagVideoInfoList, VideoInfo newVideoInfo)
	{
		if (tagVideoInfoList.contains(newVideoInfo))
			return true;
		
		Iterator<VideoInfo> videoInfoIterator = tagVideoInfoList.iterator();
		
		while(videoInfoIterator.hasNext())
		{
			if (videoInfoIterator.next().videoFileLocation.equals(newVideoInfo.videoFileLocation))
				return true;
		}
		
		return false;
	}

}
