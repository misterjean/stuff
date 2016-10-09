package com.java.facetracking.controller;

import com.java.facetracking.view.*;
import com.java.facetracking.model.*;

import java.awt.Color;
import java.awt.Dialog;
import java.awt.Image;
import java.awt.image.*;
import javax.imageio.*;
import javax.swing.JDialog;
import javax.swing.JOptionPane;

import java.io.*;
import java.awt.Point;
import java.util.ArrayList;
import java.util.List;

public class MainController {
	
	private FaceTrackingView view;
	private BufferedImage currentImage;
	
	private List<FaceDetector> faceDetectors;
	
	public MainController(FaceTrackingView view) 
	{
		// constructor
		this.view = view;
		
		faceDetectors = new ArrayList<FaceDetector>();
		faceDetectors.add(new ColorComparison());
		faceDetectors.add(new ImageComparison());
		
		view.setController(this);		
	}
	
	public List<FaceDetector> getDetectors()
	{
		return faceDetectors;
	}
	
	public void loadImageFromFile() {
		File file = view.showOpenFileDialog();
		
		if (file != null) {
			try {
				currentImage = ImageIO.read(file);
			}
			catch (IOException e) {
				
			}
			view.showImage(currentImage);
		}
	}
	
	public void takeWebcamPicture() {		
		WebcamInterface webcam = new WebcamInterface();
		try {
			currentImage = webcam.getWebcamPicture();
		}
		catch (Exception e) {
			JOptionPane.showMessageDialog(view,  
					"Error taking picture: " + e.getMessage(),
					"Error taking picture",
					JOptionPane.ERROR_MESSAGE);
		}
		view.showImage(currentImage);
	}
	
	public void doFaceDetection(int processorIndex) {
		DetectedFace detectedFace;
		if (processorIndex < 0) {
			JOptionPane.showMessageDialog(view,
					"Please select a face detection method below",
				    "Processing Error",
				    JOptionPane.ERROR_MESSAGE);
			return;
		}
		try {
			detectedFace = faceDetectors.get(processorIndex).processImage(currentImage);
			view.showImage(highlightSkinAndCentre(currentImage, detectedFace));
		} catch (Exception e) {
			JOptionPane.showMessageDialog(view,
					"Error processing image: " + e.getMessage(),
				    "Processing Error",
				    JOptionPane.ERROR_MESSAGE);
		}		
	}	
	
	public BufferedImage highlightSkinAndCentre(BufferedImage srcImage, DetectedFace detectedFace)
	{
		// Do a copy of the image so we don't modify the original
		WritableRaster raster = srcImage.copyData(null);
		BufferedImage outputImage = new BufferedImage(srcImage.getColorModel(),
				raster, 
				srcImage.isAlphaPremultiplied(), 
				null);
		
		// Highlight the skin pixels
		int highlightColor = 0xFFFF0000;
		int i;
		for (i = 0; i < detectedFace.facePoints.size(); i++) {			
			outputImage.setRGB(detectedFace.facePoints.get(i).x, detectedFace.facePoints.get(i).y, highlightColor);
		}
		
		// Highlight the centre
		highlightColor = 0xFF00FF00;
		for (i = 0; i < srcImage.getWidth(); i++) {
			outputImage.setRGB(i, detectedFace.faceCenter.y, highlightColor);
		}
		for (i = 0; i < srcImage.getHeight(); i++) {
			outputImage.setRGB(detectedFace.faceCenter.x, i, highlightColor);
		}
		
		return outputImage;
	}
	
	public static void main(String[] args) 
	{
		FaceTrackingView view = new FaceTrackingView();
		MainController controller = new MainController(view);
		view.setVisible(true);
		
	}

	public void increaseContrast() {
		if (currentImage != null)
		{
			ImageProcessor.SetContrast(currentImage, 1);
			view.showImage(currentImage);
		}
		
	}
	
	public void decreaseContrast() {
		if (currentImage != null)
		{
			ImageProcessor.SetContrast(currentImage, -1);
			view.showImage(currentImage);
		}
		
	}

	public void downSample() {
		ImageProcessor.downsample(currentImage, 4);
		view.showImage(currentImage);
		
	}

}
