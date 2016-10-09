package com.android.heyjane.io.transmit;

import java.util.List;

import com.android.heyjane.configuration.NetworkPeer;

public abstract class UnicastTransmitter extends Transmitter {

	protected List<NetworkPeer> destinationIPs;
	public UnicastTransmitter(int numRedundantPackets, int sleepTimeMs, List<NetworkPeer> list, Boolean sendRawData) {
		super(numRedundantPackets, sleepTimeMs, sendRawData);
		
		this.destinationIPs = list;
	}
	
	protected void initialize()
	{
		
	}
}
