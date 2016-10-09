package com.android.heyjane.io.transmit;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.android.heyjane.configuration.NetworkPeer;

public class TCPUnicastTransmitter extends UnicastTransmitter
{
	static final int MTU_SIZE = 1500;
	static int MY_PORT = 30001;
	
	private List<Socket> sockets;
	
	public TCPUnicastTransmitter(int numRedundantPackets, int waitTimeMs, List<NetworkPeer> list) throws IOException
	{
		super(numRedundantPackets, waitTimeMs, list, true);		
	}

	@Override
	public void close() throws IOException 
	{
		for(Iterator<Socket> currentDestination = sockets.iterator(); currentDestination.hasNext();)
		{
			currentDestination.next().close();		
		}
	}

	@Override
	protected void sendData(byte[] data, int length)
	{
		
		for(Iterator<Socket> currentDestination = sockets.iterator(); currentDestination.hasNext();)
		{			
			Socket thisSocket = currentDestination.next();
			boolean wasAttemptSuccessful = false;
			
			if (thisSocket.isConnected())
			{
				int maxRetries = 10;				
				while (maxRetries > 0)
				{
					try { 
						new DataOutputStream(thisSocket.getOutputStream()).write(data,  0, length);
						wasAttemptSuccessful = true;
						break;
					} catch (IOException e) {
						maxRetries--;
						System.out.println("Retrying transmission...");
						try {
							Thread.sleep(40);
						} catch (InterruptedException e1) {
							e1.printStackTrace();
						}
					}	 
				}
				
			}
			
			if (wasAttemptSuccessful)
				continue;
			
			try
			{
				thisSocket.close();
			} catch (Exception e)
			{
				e.printStackTrace();
			}
		}
	}

	@Override
	protected void initialize() {
		sockets = new ArrayList<Socket>();
		
		for(Iterator<NetworkPeer> currentDestination = destinationIPs.iterator(); currentDestination.hasNext();)
		{
			Socket socket = null;
			try
			{
				socket = new Socket(currentDestination.next().ipAddress, MY_PORT);			
			}
			catch (Exception e)
			{
				e.printStackTrace();
				continue;
			}
			sockets.add(socket);
		}
		
	}	
}