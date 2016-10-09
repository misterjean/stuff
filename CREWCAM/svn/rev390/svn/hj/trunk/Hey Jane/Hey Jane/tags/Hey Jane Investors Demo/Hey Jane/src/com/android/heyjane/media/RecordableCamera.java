package com.android.heyjane.media;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import com.android.heyjane.configuration.ConfigurationManager;
import com.android.heyjane.videoviewer.VideoInfo;

import android.hardware.Camera;
import android.media.*;
import android.util.Log;
import android.view.SurfaceHolder;

// TODO: add some code to ensure camera is acquired before acquiring recorder ... 

public class RecordableCamera {
	private static final String TAG = "RecordableCamera";
	private static RecordableCamera m_instance = null;
	private SurfaceHolder m_surfaceHolder = null;
	private MediaRecorder m_recorder = null;
	private Camera m_camera = null;
	private boolean m_isRecording = false;

	public static RecordableCamera getInstance() {
		if (m_instance == null) {
			m_instance = new RecordableCamera();
		}
		return m_instance;
	}
	
	private RecordableCamera() {
		m_recorder = null;
		m_camera = null;
		m_isRecording = false;
	}

	// increase the usage count
	public void acquire(SurfaceHolder surfaceHolder) {
		acquireCamera();
		m_surfaceHolder = surfaceHolder;
	}

	// decrease the usage count
	public void release() {
		releaseCamera();
		releaseRecorder();
		m_isRecording = false;
	}

	public boolean isRecording() {
		return m_isRecording;
	}

	public VideoInfo startRecording() throws Exception {
		// initialise 
	  VideoInfo videoInfo = acquireRecorder();
		m_recorder.start();
		m_isRecording = true;
		return videoInfo;
	}

	public void stopRecording() {
		// opposite of initialise 
		m_recorder.stop();
		releaseRecorder();
		m_isRecording = false;
		
		// this stops the preview ...
		m_camera.stopPreview();
	}
	
	public Camera getHardwareCamera() {
		return m_camera;
	}
	
	private void acquireCamera() {
		try {
			m_camera = Camera.open();
		} catch (Exception e) {
			Log.d(TAG, "Failed to get camera: " + e.getMessage());
		}
	}

	private void releaseCamera() {
		if (m_camera != null) {
			m_camera.release();
			m_camera = null;
		}
	}
	
	private VideoInfo acquireRecorder() throws Exception {
		m_recorder = new MediaRecorder();		
		m_camera.unlock();
		m_recorder.setCamera(m_camera);			

		// Create the videoInfo object
		VideoInfo newVideoInfo = new VideoInfo();		

		// set up the recorder: TODO: change this to set up the format/size properly
		m_recorder.setAudioSource(MediaRecorder.AudioSource.CAMCORDER);
		m_recorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);
		m_recorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);
		
		m_recorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
		m_recorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
		m_recorder.setOutputFile(newVideoInfo.videoFileLocation);
		m_recorder.setVideoSize(1280, 720);
		
		m_recorder.setPreviewDisplay(m_surfaceHolder.getSurface());
		
		m_recorder.prepare();
		
		return newVideoInfo;
	}
	
	private void releaseRecorder() {
		if (m_recorder != null) {
			m_recorder.reset();
			m_recorder.release();
			m_recorder = null;
		}
		
		if (m_camera != null) {
			m_camera.lock();
		}
	}
}
