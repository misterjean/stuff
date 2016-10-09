package com.android.heyjane.io.receive;

import java.io.IOException;

import com.android.heyjane.io.transmit.Transmitter;
import com.android.heyjane.io.transmit.UDPMulticastTransmitter;

import android.os.AsyncTask;

public class HeartbeatSender extends AsyncTask <Void, Void, Void>
{
	Transmitter transmitter;
	String ipAddress;
	
	public HeartbeatSender(String ipAddress) throws IOException
	{
		this.ipAddress = ipAddress;
		
		transmitter = new UDPMulticastTransmitter(10, 3);	
	}

	@Override
	protected Void doInBackground(Void... params) 
	{
		while (true)
		{
			try {
				transmitter.transmitData(CreateHeartbeatPacket());
				Thread.sleep(1000,0);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return null;
			}
		}
	}
	
	protected byte[] CreateHeartbeatPacket()
	{
		String message = "HEARTBEAT_FROM:" + ipAddress;
		return message.getBytes();
	}
}
