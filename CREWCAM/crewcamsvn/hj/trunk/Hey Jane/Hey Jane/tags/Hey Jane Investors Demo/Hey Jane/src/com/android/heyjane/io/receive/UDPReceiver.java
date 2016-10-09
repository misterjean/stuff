package com.android.heyjane.io.receive;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import com.android.heyjane.SplashActivity;
import com.android.heyjane.VideoViewerActivity;

public class UDPReceiver extends Receiver
{
	
	private static final int MTU_SIZE = 1500;
	
	private MulticastSocket mcSocket;
	
	public UDPReceiver(ReceiveNotificationHandler notificationHandler) throws IOException
	{		
		super(notificationHandler);	
		
		mcSocket = new MulticastSocket(30000);
		mcSocket.joinGroup(InetAddress.getByName("224.0.0.0"));		
	}    

	@Override
	protected Void doInBackground(Void... params) 
	{
		while(true)
		{
			DatagramPacket packet; //also contains the port number and ip of the sender. 
			//TODO: need to get the received lenght from the packet.
			byte[] buffer = new byte[MTU_SIZE];
			packet = new DatagramPacket(buffer, buffer.length);
			try {
				mcSocket.receive(packet);
				/* RecievingFileProgress fileReceivedData = */ decoder.receiveData(buffer,packet.getLength());
				
				// None of this will *ever* happen since we're just processing heartbeats anyway
//				if (fileReceivedData != null)
//				{
//					publishProgress(fileReceivedData);
//					
//					if (fileReceivedData.error == true)
//					{
//						return null;
//					}
//				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
