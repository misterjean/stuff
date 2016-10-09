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
	
	int lastSequence = -1;
	int lostSequences = 0;
	
	Boolean wasFileClosed = false;
	
	public RecievingFileProgress receiveData(long ssrc, int sequenceNumber , byte []data, int length) 
	{
		FileOutputStream oStream = null;				

		if (length > 0)
		{
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
					fileProgress.error = true;
					fileProgress.errorString = "Error parsing metadata: " +  e.getMessage();					
				}
			}	
			return fileProgress;
		}
		
		if (sequenceNumber == lastSequence)
		{
			// Ignore duplicates
			return null;
		}
		if (length == 0 && wasFileClosed)
		{
			// we already received the whole file
			return null;
		}
		wasFileClosed = false;
		
		if (sequenceNumber != (lastSequence + 1))
		{
			lostSequences+= sequenceNumber - lastSequence - 1;
		}
		
		if (sequenceNumber < lastSequence)
		{
			// New data, somehow we didn't received the EOD frame
			lostSequences = 0;
		}
		
		lastSequence = sequenceNumber;		
		
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
				// TODO Auto-generated catch block
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
				fileProgress.percentLost = 100*((float)lostSequences/sequenceNumber);
				oStream.flush();
				oStream.close();
				activeMediaStreams.remove(ssrc);
				wasFileClosed = true;
				lastSequence = -1;
				lostSequences = 0;
				fileProgress.isVideoComplete = true;
				return fileProgress;
			} 
			catch (IOException e) 
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
				fileProgress.error = true;
				fileProgress.errorString = "Error saving the file: " + e.getMessage();
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
			fileProgress.errorString = "Error writing terminator: " + e.getMessage();
			return fileProgress;
		}
		
		return fileProgress;
		
	}

	private void ProcessHeartbeat(String heartbeatString) {
		String ipAddress = heartbeatString.substring(heartbeatString.indexOf(":") + 1, heartbeatString.length());
		
		if (ipAddress.equals(ConfigurationManager.myIPAddress))
			return;
		
		PeerList.ProcessHeartbeat(ipAddress);
		
	}
}



