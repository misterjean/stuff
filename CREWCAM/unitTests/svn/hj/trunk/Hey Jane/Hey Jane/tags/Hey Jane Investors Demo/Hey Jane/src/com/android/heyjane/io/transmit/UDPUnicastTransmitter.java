package com.android.heyjane.io.transmit;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Iterator;
import java.util.List;

import com.android.heyjane.configuration.NetworkPeer;

public class UDPUnicastTransmitter extends UnicastTransmitter
{
	static final int MTU_SIZE = 1500;
	static int MY_PORT = 30000;
	
	private DatagramSocket mySocket;
	
	public UDPUnicastTransmitter(int numRedundantPackets, int waitTimeMs, List<NetworkPeer> list) throws IOException
	{
		super(numRedundantPackets, waitTimeMs, list, false);
		mySocket = new DatagramSocket();
	}

	@Override
	public void close() throws IOException {
		
	}

	@Override
	protected void sendData(byte[] data, int length)
			throws IOException {
		
		for(Iterator<NetworkPeer> currentDestination = destinationIPs.iterator(); currentDestination.hasNext();)
		{
			DatagramPacket packet = new DatagramPacket(data, length,
					InetAddress.getByName(currentDestination.next().ipAddress),MY_PORT);
	
			mySocket.send(packet);
		}
	}	
}