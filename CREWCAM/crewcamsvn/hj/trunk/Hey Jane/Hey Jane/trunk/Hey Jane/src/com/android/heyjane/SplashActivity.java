package com.android.heyjane;

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.configuration.NetworkPeer;
import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.io.receive.HeartbeatSender;
import com.android.heyjane.io.receive.PacketProcessor;
import com.android.heyjane.io.receive.RTPDecoder;
import com.android.heyjane.io.receive.RecievingFileProgress;
import com.android.heyjane.io.receive.TCPReceiver;
import com.android.heyjane.io.receive.UDPReceiver;
import com.android.heyjane.io.transmit.UDPUnicastTransmitter;
import com.android.heyjane.media.RecordableCamera;
import com.android.heyjane.videoviewer.VideoInfo;
import com.android.heyjane.MediaActivity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.net.ConnectivityManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiManager.MulticastLock;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.Toast;

public class SplashActivity extends Activity implements OnClickListener{
	/** Called when the activity is first created. */

	Button startButton;
	EditText ownerName;
	
	private SharedPreferences myPreferences;

	
	@Override
	public void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);		
		
		setContentView(R.layout.splash);
		
		if (!validateConfiguration())
		{ 
			finish();
			return;
		}

		InitializeButtons();	
		
		myPreferences = getSharedPreferences("hey_jane_preferences", 0);
		ownerName.setText(myPreferences.getString("USERNAME", "Your Name"));
	}
	
	@Override
	public void onPause() 
	{
		super.onPause();
		SharedPreferences.Editor editor = myPreferences.edit();
		editor.putString("USERNAME", ownerName.getText().toString());
		editor.commit();		
	}

	private boolean validateConfiguration() 
	{
		// Try to create the Pictures directory if needed
		if (!(new File(VideoInfo.VIDEO_LOCATION).exists()) && !(new File(VideoInfo.VIDEO_LOCATION).mkdir()))
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("Unable to create video directory.")
			       .setCancelable(false)
			       .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			           public void onClick(DialogInterface dialog, int id) {
			                dialog.dismiss();
			           }
			       }).show();
			return false;			
		}
		
		return true;
	}
	
	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
	  savedInstanceState.putString("USERNAME", ownerName.getText().toString());
	  ownerName.setText(savedInstanceState.getString("USERNAME"));
	  super.onSaveInstanceState(savedInstanceState);
	}
	
	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState) {
	  super.onRestoreInstanceState(savedInstanceState);

	  ownerName.setText(savedInstanceState.getString("USERNAME"));
	}

	private void InitializeButtons() 
	{		
		startButton = (Button)findViewById(R.id.startButton);        
		startButton.setOnClickListener(this);
		
		ownerName = (EditText)findViewById(R.id.owner);		
	}

	public void onClick(View v) { 
		if (v == startButton)
		{
			ConfigurationManager.owner = ownerName.getText().toString();
			
			finish();
		}
	}
}