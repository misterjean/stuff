package com.android.heyjane.io.transmit;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Random;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.AsyncTask;

import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.videoviewer.VideoInfo;

public abstract class Transmitter extends AsyncTask<VideoInfo, Integer, Void> implements OnCancelListener
{
	protected RTPEncoder rtpEncoder = new RTPEncoder();
	protected long sourceIdentifier;
	protected Random randomGenerator = new Random();
	protected int sequenceNumber;
	protected int  bufferSize = 1300;

	private int sleepTimeMs;
	private static int HEYJANE_RANDOM_SEED = 19672789;
	private static int HEYJANE_RTP_SEQ_START = 1;
	private Boolean sendRawData = false;
	
	private ProgressDialog dialog;
		
	public void onCancel(DialogInterface dialog) 
	{
		if (dialog == this.dialog)
		{
			dialog.dismiss();
			this.cancel(true);
		}
	}	
	
	public Transmitter(int numRedundantPackets, int sleepTimeMs, Boolean sendRawData)
	{
		sourceIdentifier = randomGenerator.nextInt(HEYJANE_RANDOM_SEED);
		sequenceNumber = HEYJANE_RTP_SEQ_START;
		
		this.sleepTimeMs = 5; 
		this.sendRawData = sendRawData; 
		
		// Start listening/sending heartbeats if we aren't already
		if (!PeerList.isRunning)
			PeerList.getInstance().execute();
	}
	
	public void SendFile(VideoInfo videoToSend, Context context) throws IOException, InterruptedException
	{
		if(PeerList.getPeers().size() == 0)
		{
			if (context != null)
			{
				AlertDialog.Builder builder = new AlertDialog.Builder(context);
				builder.setMessage("Sorry, but there is nobody around to receive the video.  Try again later.")
				       .setCancelable(false)
				       .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
				           public void onClick(DialogInterface dialog, int id) {
				                dialog.dismiss();
				           }
				       }).show();
			}
		}
		else
		{
			if (context != null)
			{
				dialog = new ProgressDialog(context);
				dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
				dialog.setMessage("Sending...");
				dialog.setCancelable(true);
				dialog.setCanceledOnTouchOutside(true); 
				dialog.show();	
			}
			this.execute(videoToSend);
		}
	}
	
	public void transmitData(byte [] data) throws IOException, InterruptedException
	{
		byte [] rtpData = RTPEncoder.encodeData(data, data.length, sourceIdentifier, sequenceNumber);
		
		sendData(rtpData, rtpData.length);
		
		Thread.sleep(sleepTimeMs, 0);

	}
	
	public abstract void close() throws IOException;
	
	protected abstract void sendData(byte [] data, int length) throws IOException;
	
	protected abstract void initialize();
	
	@Override
	protected Void doInBackground(VideoInfo... params) 
	{
		try {			
			
			initialize();
			
			String videoInfoString = "NAME:" + params[0].name + "\nOWNER:" + params[0].metadata.owner + "\nTAGS:" + params[0].tagsString + "\n";											
			
			sendVideoInfo(videoInfoString);												
			
			if (!sendVideoFile(params[0]))
				return null;
			
			sendEndOfFrame();
			
			close();
		} catch (Exception e) {
			
			e.printStackTrace();
		} 
		
		return null;	
		
	}

	private void sendEndOfFrame() throws IOException {
		if(!sendRawData)
		{
			byte[] eodFrame = RTPEncoder.encodeData(null, 0, sourceIdentifier, sequenceNumber);
			sendData(eodFrame, eodFrame.length);
		}
	}

	private Boolean sendVideoFile(VideoInfo videoInfo)
			throws FileNotFoundException, IOException, InterruptedException {
		File videoFiles = new File(videoInfo.videoFileLocation);
		FileInputStream fileStream = new FileInputStream(videoFiles);
		byte [] dataToSend = new byte[bufferSize];					
		long totalBytes = videoFiles.length();
		long bytesSent = 0;
		byte [] encodedDataToSend = null;
		
		while (true)
		{
			if (isCancelled())
			{
				return false;
			}
			
			int length = fileStream.read(dataToSend);
			
			if (length == -1)
				break;
			
			encodedDataToSend = null;
			
			if (!sendRawData)
			{
				encodedDataToSend = RTPEncoder.encodeData(dataToSend, length, sourceIdentifier, sequenceNumber);				
			}
			
			bytesSent += length;
			
			// If the percentage complete is divisible by 5
			if ((int)(100*((float)bytesSent/(float)totalBytes))%5 == 0)
			{
				publishProgress((int)(100*((float)bytesSent/(float)totalBytes)));
			}
			
			if (sendRawData)
			{
				sendData(dataToSend, length);
			}
			else
			{
				sendData(encodedDataToSend, encodedDataToSend.length);
			}
			
			Thread.sleep(sleepTimeMs, 0);					

			sequenceNumber++;
		}
		
		fileStream.close();
		return true;
	}

	private void sendVideoInfo(String videoInfoString) throws IOException, InterruptedException {		
		byte [] encodedDataToSend = null;
		
		if (!sendRawData)
		{
			encodedDataToSend = RTPEncoder.encodeData(videoInfoString.getBytes(), videoInfoString.getBytes().length, sourceIdentifier, sequenceNumber);				
		}			
	
		if (sendRawData)
		{
			sendData(videoInfoString.getBytes(), videoInfoString.getBytes().length);
		}
		else
		{
			sendData(encodedDataToSend, encodedDataToSend.length);
		}			
		
		sequenceNumber++;
	}
	
	@Override
	protected void onProgressUpdate(Integer... params) 
	{
		if (dialog != null)
			dialog.setProgress(params[0]);
    }
	
	@Override
	protected void onPostExecute(Void result) {
		try {
			close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (dialog != null)
		{
			dialog.dismiss();
		}
    }

	public void SendFile(VideoInfo videoInfo) 
	{
		try {
			SendFile(videoInfo, null);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 	
	}
	

	
}
