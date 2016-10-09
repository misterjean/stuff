package com.android.heyjane.configuration;

public class NetworkPeer 
{
	public NetworkPeer(String ipAddress, int i) {
		this.ipAddress = ipAddress;
		this.secondsLeft = i;
	}
	
	public String ipAddress;
	public int secondsLeft;

}