package com.android.heyjane;

import java.io.File;
import java.io.IOException;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.configuration.PeerList;
import com.android.heyjane.media.RecordableCamera;
import com.android.heyjane.videoviewer.VideoInfo;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.NotificationManager;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.PixelFormat;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnVideoSizeChangedListener;
import android.os.Bundle;
import android.os.Handler;
import android.view.Display;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class MediaActivity extends Activity implements SurfaceHolder.Callback, MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener, OnClickListener, OnVideoSizeChangedListener, OnCancelListener  {

	SurfaceView surfaceView;
	SurfaceHolder surfaceHolder;
	Button mediaPlayerBack;
	private int videoWidth;
	private int videoHeight;
	private boolean isVideoReady;
	private boolean isVideoSizeKnown;
	private MediaPlayer mediaPlayer;	

	private VideoInfo videoInfo;
	private static final int DIALOG_VIDEO_INFO = 1;

	private Button stopMediaPlayer;

	// Used so we know if this activity is done.  This is a slightly hackish way of keeping
	// our Handler from trying to create a dialog on an activity that no longer exists
	private Boolean isComplete = false;	


	@Override
	protected Dialog onCreateDialog(int id)
	{
		switch (id)
		{
		case DIALOG_VIDEO_INFO:
			LayoutInflater factory = LayoutInflater.from(this);
			final View textEntryView = factory.inflate(R.layout.videoinfodialog, null);	      

			final EditText videoTitle = (EditText)textEntryView.findViewById(R.id.videoTitle); 
			final EditText videoTags = (EditText)textEntryView.findViewById(R.id.videoTags);

			videoTitle.requestFocus();

			return new AlertDialog.Builder(MediaActivity.this)
			.setCancelable(false)
			.setTitle("Video Information")
			.setView(textEntryView)
			.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int whichButton) {
					videoInfo.name = videoTitle.getText().toString();
					if (videoInfo.name.equals(""))
						videoInfo.name = "Unknown";
					videoInfo.metadata.owner = ConfigurationManager.owner;
					videoInfo.tagsString = videoTags.getText().toString();
					videoInfo.tagsString += "\n\0";		// Make sure there is a new-line and a null-terminator.  Otherwise we can have problems if the user doesn't enter anything 	         

					try {
						videoInfo.writeMetaData();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 

					// This will slow things down, but not too badly
//					videoInfo.generateThumbnailSync();
					ConfigurationManager.getTransmitter().SendFile(videoInfo);
					returnToMainScreen(); 

				}
			}).create();
		}
		return null;
	}



	@Override
	public void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);

		setContentView(R.layout.mediaplayer);				

		getWindow().setFormat(PixelFormat.UNKNOWN);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);

		surfaceView = (SurfaceView)findViewById(R.id.mediaPlayerSurface);
		surfaceHolder = surfaceView.getHolder();
		surfaceHolder.addCallback(this);	
		surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

		stopMediaPlayer = (Button)findViewById(R.id.stopMediaPlayer);
		stopMediaPlayer.setOnClickListener(this);
	}	

	@Override
	public void onPause()
	{
		super.onPause();		 
		releaseMediaPlayer();
		doCleanUp();
	}

	@Override
	public void onDestroy()
	{
		super.onDestroy();
		releaseMediaPlayer();
		doCleanUp();
	}

	private void releaseMediaPlayer() {
		if (mediaPlayer != null)
		{
			mediaPlayer.release();
			mediaPlayer = null;
		}

	}

	private void doCleanUp() {
		videoWidth = 0;
		videoHeight = 0;
		isVideoReady = false;
		isVideoSizeKnown = false;		
	}

	public void start() throws Exception
	{
		Bundle extras = getIntent().getExtras();
		if (extras != null)
		{
			String videoFile = extras.getString("videoFile");
			if (videoFile != null)
			{
				playVideo(new File(videoFile));
			}
			return;
		}

		// Otherwise we record a video
		recordVideo();
	}

	public void playVideo(File video) throws Exception
	{
		mediaPlayer = new MediaPlayer();    

		mediaPlayer.setDataSource(video.getPath());
		mediaPlayer.setDisplay(surfaceHolder);    	
		mediaPlayer.prepare();
		mediaPlayer.setOnCompletionListener(this);  
		mediaPlayer.setOnPreparedListener(this);
		mediaPlayer.setOnVideoSizeChangedListener(this);
		mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);				 
	}

	public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
		if (width == 0 || height == 0) {
			return;
		}
		isVideoSizeKnown = true;
		videoWidth = width;
		videoHeight = height;

		if (isVideoReady)
		{
			startVideoPlayback();
		}         
	}

	private void startVideoPlayback() 
	{		
		surfaceHolder.setFixedSize(videoWidth, videoHeight);
		mediaPlayer.start();

	}

	public void onCompletion(MediaPlayer mp) {
		returnToMainScreen();
	}

	public void reset() {

	}

	public void release() {

	}

	public void onPrepared(MediaPlayer mediaPlayer) 
	{		
		isVideoReady = true;

		if (isVideoSizeKnown)
			mediaPlayer.start();				
	}

	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		// TODO Auto-generated method stub

	}

	public void surfaceCreated(SurfaceHolder holder) {
		try
		{
			start();
		}
		catch (Exception e)
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("Darn it, there was a problem with the media player: " + e.getMessage())
			.setCancelable(false)
			.setOnCancelListener(this)
			.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			}).show();

			e.printStackTrace();
		}

	}

	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub

	}

	public static SurfaceHolder getSurface() {
		// TODO Auto-generated method stub
		return null;
	}

	public void recordVideo() throws Exception {
		RecordableCamera.getInstance().acquire(surfaceHolder);
		videoInfo = RecordableCamera.getInstance().startRecording();

		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			public void run() {
				if (RecordableCamera.getInstance().isRecording() && !isComplete)
				{
					RecordableCamera.getInstance().stopRecording();
					RecordableCamera.getInstance().release();
					showDialog(DIALOG_VIDEO_INFO);
				}

				// Otherwise somebody probably pressed the stop button

			}
		},8000);

	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
	    if (keyCode == KeyEvent.KEYCODE_BACK) {
	    	stopAndReturnToMainScreen();
	    	return true;
	    }
	    return super.onKeyDown(keyCode, event);
	}
	
	public void returnToMainScreen()
	{
		isComplete = true;
		super.finish();
	}

	public void onClick(View v) {
		if (v == stopMediaPlayer)
		{
			stopAndReturnToMainScreen();				
		}		
	}



	private void stopAndReturnToMainScreen() 
	{
		if (RecordableCamera.getInstance() != null && RecordableCamera.getInstance().isRecording() && !isComplete)
		{
			RecordableCamera.getInstance().stopRecording();
			RecordableCamera.getInstance().release();
			showDialog(DIALOG_VIDEO_INFO);	
			
		}
		else if (mediaPlayer != null && mediaPlayer.isPlaying())
		{
			mediaPlayer.stop();
			returnToMainScreen();
		}
	}

	public void onCancel(DialogInterface dialog) 
	{
		returnToMainScreen();		
	}

}


