package com.android.heyjane.io;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import android.app.AlertDialog;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiManager.MulticastLock;
import android.widget.Toast;

import com.android.heyjane.R;
import com.android.heyjane.VideoViewerActivity;
import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.io.receive.HeartbeatSender;
import com.android.heyjane.io.receive.ReceiveNotificationHandler;
import com.android.heyjane.io.receive.TCPReceiver;
import com.android.heyjane.io.receive.UDPReceiver;
import com.android.heyjane.videoviewer.VideoInfo;

public final class IOManager implements ReceiveNotificationHandler
{
	static private ArrayList<OnVideoReceivedListener> videoReceivedListeners = new ArrayList<OnVideoReceivedListener>();

	private UDPReceiver udpReceiver;
	private TCPReceiver tcpReceiver;	
	
	private Context context = null;

	private ProgressDialog dialog;

	private NotificationManager notificationManager;
	
	private static IOManager instance = new IOManager();
	
	private boolean isInitialized = false;
	
	private IOManager()
	{
		
	}
		
	private void sendNotificationOfNewVideo(VideoInfo newVideo) {
		int icon = R.drawable.heyjane;
		long when = System.currentTimeMillis();
		
		CharSequence contentTitle = "Video Received!";
		CharSequence contentText = "Video received from " + newVideo.metadata.owner + "!";
		
		Notification notification = new Notification( icon, contentText, when);
		
		Intent notificationIntent =
				new Intent(context, VideoViewerActivity.class);
		
		PendingIntent contentIntent =
				PendingIntent.getActivity(context, 0, notificationIntent, 0);

		notification.setLatestEventInfo(
				context.getApplicationContext(),
				contentTitle,
				contentText,
				contentIntent);

		notificationManager.notify( 1, notification );
	}
	
	public boolean tryToInitialize(Context context)
	{
		if (isInitialized)
			return true;
		
		this.context = context;
		
		notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		
		try
		{
			getWiFiLock();   			
			configureIO();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return false;
		}
		
		isInitialized = true;
		return true; 
	}
	
	public void setOnVideoReceivedListner(OnVideoReceivedListener listner)
	{
		if (!videoReceivedListeners.contains(listner))
		{
			videoReceivedListeners.add(listner);
		}
		else
		{
			System.out.println("Blocked attempt for multiple listeners!");
		}
	}
	
	public static IOManager getInstance()
	{
		return instance;
	}
	
	private String getIPAddress() {
		WifiManager wifiManager = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
		WifiInfo wifiInfo = wifiManager.getConnectionInfo();
		String ipAddress = String.format("%d.%d.%d.%d",
				(wifiInfo.getIpAddress() & 0xff),
				(wifiInfo.getIpAddress() >> 8 & 0xff),
				(wifiInfo.getIpAddress() >> 16 & 0xff),
				(wifiInfo.getIpAddress() >> 24 & 0xff));				

		ConfigurationManager.myIPAddress = ipAddress;
		return ipAddress;
	}
	
	private void getWiFiLock() {
		WifiManager wifi = (WifiManager)context.getSystemService( Context.WIFI_SERVICE );
		MulticastLock mcLock = wifi.createMulticastLock("mylock");
		mcLock.acquire();
	}
	
	private void configureIO() 
	{
		String ipAddress = getIPAddress();
		try {
			udpReceiver = new UDPReceiver(this); 			
		} catch (IOException e) {
			Toast.makeText(context, "Unable to listen on UDP socket.", 1000).show();
			e.printStackTrace();
		}

		try {
			tcpReceiver = new TCPReceiver(this);
		}
		catch (IOException e) {
			Toast.makeText(context, "Unable to listen on TCP socket.", 1000).show();
			e.printStackTrace();
		}

		try
		{
			new HeartbeatSender(ipAddress).execute();
		}
		catch (Exception e)
		{
			Toast.makeText(context, "Unable setup heartbeat sender.", 1000).show();
			e.printStackTrace();
		}

		// Start receiving for both UDP and TCP
		if (udpReceiver != null)
			udpReceiver.execute();

		if (tcpReceiver != null)
			tcpReceiver.execute();
	}

	@Override
	public void onVideoReceived(VideoInfo videoInfo) 
	{
		if (dialog != null)
		{
			dialog.dismiss();
			dialog = null;
		}
		
		// Don't do this till we understand why we're getting so many notifications
//		sendNotificationOfNewVideo(videoInfo);
		
		Iterator<OnVideoReceivedListener> listeners = videoReceivedListeners.iterator();
		
		while (listeners.hasNext())
			listeners.next().onVideoReceived(videoInfo);
		
	}

	@Override
	public void onError(String errorMessage) {
		Toast.makeText(context, errorMessage, 2000).show();
	}

	@Override
	public void onStartVideoReception(VideoInfo videoInfo) 
	{
		String dialogString = "";
		if (videoInfo.metadata.owner != null)
		{
			dialogString = "Hang tight!  Incoming video from " + videoInfo.metadata.owner + "...";
		}
		else
		{
			dialogString = "Hang tight!  Incoming video...";
		}
		Toast.makeText(context, dialogString, 1000).show();		
	}

	public static void clearOnVideoReceivedListener(OnVideoReceivedListener listener) 
	{
		if (videoReceivedListeners.contains(listener))
		{
			videoReceivedListeners.remove(listener);
		}
		
	}
}
