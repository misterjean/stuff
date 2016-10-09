package com.android.heyjane.configuration;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


import android.os.AsyncTask;

public class PeerList extends AsyncTask <Void, Void, Void> 
{
	
	static private List<NetworkPeer> networkPeers = new ArrayList<NetworkPeer>();	
	
	static private PeerList instance = new PeerList();

	public static boolean isRunning = false;
	
	private PeerList()
	{
		
	}
	
	public static PeerList getInstance()
	{
		return instance;
	}

	public static void ProcessHeartbeat(String ipAddress)
	{
		for(Iterator<NetworkPeer> i = networkPeers.iterator(); i.hasNext();)
		{
			NetworkPeer peer = i.next();
			if(peer.ipAddress.equals(ipAddress))
			{
				peer.secondsLeft = 10;
				return;
			}
		}
		
		networkPeers.add(new NetworkPeer(ipAddress, 10));
	}

	
	public static List<NetworkPeer> getPeers()
	{
		return networkPeers;
	}

	@Override
	protected Void doInBackground(Void... params) 
	{
		isRunning = true;
		while (true)
		{
			try 
			{
				for(Iterator<NetworkPeer> i = networkPeers.iterator(); i.hasNext();)
				{
					NetworkPeer peer = i.next();
					peer.secondsLeft--;
					if (peer.secondsLeft == 0)
					{
						i.remove();
					}
				}
				Thread.sleep(1000, 0);
			} catch (Exception e) {
				e.printStackTrace();
				
				// Hopefully this was just temporary....
				try {
					Thread.sleep(5000, 0);
				} catch (InterruptedException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		}	
	}

}
