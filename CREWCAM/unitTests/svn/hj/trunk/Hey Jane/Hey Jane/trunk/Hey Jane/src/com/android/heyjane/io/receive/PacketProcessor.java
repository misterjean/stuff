package com.android.heyjane.io.receive;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Hashtable;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.videoviewer.VideoInfo;

public class PacketProcessor
{
	Hashtable activeMediaStreams;	
	RecievingFileProgress fileProgress = new RecievingFileProgress();
	
	public PacketProcessor()
	{
		activeMediaStreams = new Hashtable();
	}
	
	Boolean wasFileClosed = false;
	
	public RecievingFileProgress receiveData(long ssrc, int sequenceNumber , byte []data, int length) 
	{
		FileOutputStream oStream = null;				

		if (length > 0)
		{
			// We have some data here, check to see if it's a heartbeat
			String heartbeatString = new String(data);
			
			if (heartbeatString.contains("HEARTBEAT_FROM:"))
			{			
				ProcessHeartbeat(heartbeatString);
				
				return null;
			}
		}
		
		// Is this the first frame?  It should contain video info...
		if (sequenceNumber == 0)
		{						
			if (new String(data).contains("NAME:"))
			{	 
				try
				{
					fileProgress.videoInfo = new VideoInfo(data);
				}
				catch (Exception e)
				{
					e.printStackTrace();
									
				}
			}	
			return fileProgress;
		}
		else if (fileProgress.videoInfo == null)
		{
			fileProgress.error = true;
			fileProgress.errorString = "Error: didn't receive the metadata for the video!";
			return fileProgress; 
		}
		
		wasFileClosed = false;
		
		//look up output file based on ssrc
		if (activeMediaStreams.containsKey(ssrc))
		{
			oStream = (FileOutputStream)activeMediaStreams.get(ssrc);
		}
		else
		{
			//need to create a new file
			try 
			{
				oStream = new FileOutputStream(fileProgress.videoInfo.videoFile);
				activeMediaStreams.put(ssrc,oStream);
			}  
			catch (FileNotFoundException e) 
			{
				e.printStackTrace();
				fileProgress.error = true;
				fileProgress.errorString = "Error opening the file: " + e.getMessage();
				return fileProgress;
			} 
		}
		
		//check if this is the end of data for this stream.
		if (length == 0)
		{
			//time to close file
			try 
			{
				oStream.close();
				activeMediaStreams.remove(ssrc);
				wasFileClosed = true;
				fileProgress.isVideoComplete = true;
				return fileProgress;
			} 
			catch (IOException e) 
			{
				e.printStackTrace();
				fileProgress.error = true;
				fileProgress.errorString = "Error closing the file: " + e.getMessage();
				return fileProgress;
			}
		}
		
		try 
		{
			oStream.write(data, 0 , length);
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
			fileProgress.error = true;
			fileProgress.errorString = "Error writing data: " + e.getMessage();
			return fileProgress;
		}
		
		return fileProgress;
		
	}

	private void ProcessHeartbeat(String heartbeatString) 
	{
		String ipAddress = heartbeatString.substring(heartbeatString.indexOf(":") + 1, heartbeatString.length());
		
		if (ipAddress.equals(ConfigurationManager.myIPAddress))
			return;
		
		PeerList.ProcessHeartbeat(ipAddress);
	}
}



