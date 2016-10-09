package com.android.heyjane.configuration;

import com.android.heyjane.io.transmit.TCPUnicastTransmitter;
import com.android.heyjane.io.transmit.Transmitter;
import com.android.heyjane.io.transmit.UDPMulticastTransmitter;
import com.android.heyjane.io.transmit.UDPUnicastTransmitter;

public class ConfigurationManager 
{
	public enum TransmitType {
		UDPMulticast, 
		UDPUnicast, 
		TCPUnicast
	}
	static public Integer redundency = 1;
	static public TransmitType transmitMethod = TransmitType.TCPUnicast;
	static public Integer sleepTimeMs = 0;
	static public String myIPAddress;
	public static String owner;
	public static String videoName = "Unnamed";
	
	public static Transmitter getTransmitter()
	{
		try
		{
		switch(transmitMethod)
		{
		case UDPMulticast:
			return new UDPMulticastTransmitter(redundency, sleepTimeMs);
		case UDPUnicast:
			return new UDPUnicastTransmitter(redundency, sleepTimeMs, PeerList.getPeers());
		case TCPUnicast:
			return new TCPUnicastTransmitter(redundency, sleepTimeMs, PeerList.getPeers());
		}
		}
		catch(Exception e)
		{
			e.printStackTrace();			
		}
		
		return null;
	}
}
