package com.android.heyjane.io.transmit;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;


public class UDPMulticastTransmitter extends Transmitter
{
	static final int MTU_SIZE = 1500;
	static int MY_PORT = 30000;
	
	private MulticastSocket mySocket;
	
	public UDPMulticastTransmitter(int numRedundantPackets, int sleepTimeMs) throws IOException
	{
		super(numRedundantPackets, sleepTimeMs, false);
		mySocket = new MulticastSocket();
		mySocket.setTimeToLive(2);
		mySocket.joinGroup(InetAddress.getByName("224.0.0.0"));
	}

	@Override
	public void close() {
		mySocket.close();
		
	}

	@Override
	protected void sendData(byte[] data, int length) throws IOException {
		DatagramPacket packet;
		
		packet = new DatagramPacket(data, length,
				InetAddress.getByName("224.0.0.0"),MY_PORT);

		mySocket.send(packet);
		
	}

	@Override
	protected void initialize() {
		// TODO Auto-generated method stub
		
	}
}