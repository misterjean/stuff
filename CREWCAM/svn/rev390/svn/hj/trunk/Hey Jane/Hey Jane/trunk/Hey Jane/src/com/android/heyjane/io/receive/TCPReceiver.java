package com.android.heyjane.io.receive;

import java.io.DataInputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import com.android.heyjane.SplashActivity;
import com.android.heyjane.VideoViewerActivity;

public class TCPReceiver extends Receiver
{
	
	private static final int MTU_SIZE = 1500;
	private static final int TCP_PORT = 30001;
	private PacketProcessor packetProcessor;
	
	private ServerSocket serverSocket;
	
	public TCPReceiver(ReceiveNotificationHandler notificationHandler) throws IOException
	{		
		super(notificationHandler);						
	}    

	@Override
	protected Void doInBackground(Void... params) 
	{		
		while(true)
		{
			DataInputStream in;
			// Wait for a connection
			Socket connectedSocket;
			try {	
				System.out.println("Trying to create a new TCP socket...");
				serverSocket = new ServerSocket(TCP_PORT);
				serverSocket.setSoTimeout(0);	// Wait forever
				connectedSocket = serverSocket.accept();	// Wait for a connection
				packetProcessor = new PacketProcessor(); 	// Create a packet processor for this connection
				in = new DataInputStream(connectedSocket.getInputStream());
			}
			catch (Exception e)
			{
				e.printStackTrace();
				try {
					serverSocket.close();
				} catch (Exception e1) {					
				}
				RecievingFileProgress fileReceivedData = new RecievingFileProgress();
				fileReceivedData.error = true;
				fileReceivedData.errorString = "Error opening connection: " + e.getMessage();
				publishProgress(fileReceivedData);
				break;
			}
			
			int sequence = 0;
			RecievingFileProgress fileReceivedData;
			byte[] buffer = new byte[1000];
			
			while(true)
			{							
				try {
					
					int length = in.read(buffer, 0, 1000);
					
					if (length == -1)
					{
						// Process the data, publish the file, and break the loop
						fileReceivedData = packetProcessor.receiveData(0, sequence, buffer, 0);		
						publishProgress(fileReceivedData);
						break;
					}
					else if (length == 0)
					{
						// Sleep, but keep receiving
						Thread.sleep(1, 0);
						continue;						
					}
					else
					{	
						// Publish any updated progress, but keep looping
						fileReceivedData = packetProcessor.receiveData(0, sequence, buffer, length);
						publishProgress(fileReceivedData);
						
						if (fileReceivedData.error)
							break;
					}
					
					fileReceivedData = null;
										
					sequence++;
				} catch (Exception e) 
				{
					e.printStackTrace();
					break;
				}
			}
			
			try 
			{
				serverSocket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return null;	
	}
}
