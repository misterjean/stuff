package com.java.facetracking.view;

import com.java.facetracking.controller.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Color;
import java.awt.Component;
import java.awt.Image;
import java.awt.image.*;
import java.io.*;
import javax.swing.*;

public class FaceTrackingView extends JFrame implements ActionListener
{	
	
	private JButton loadImage;
	private JButton takeWebcamPicture;
	private JButton doFaceDetection;
	private JButton findFaceCentre;
	private JButton increaseContrast;
	private JButton decreaseContrast;
	private JButton downSample;
	private JList	faceDetectors;
	
    private MainController faceTrackingController;
    private ImagePanel imagePanel;
	
	public FaceTrackingView ()
	{   
		// start constructor
		setLayout(null);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		pack();
		setBounds (300, 300, 525, 500);
		setTitle ("View");
		
		loadImage = new JButton ("Load static image");
		loadImage.setBounds(10, 10, 180, 20);
		add (loadImage);
		loadImage.addActionListener(this);
		
		takeWebcamPicture = new JButton ("Take webcam picture");
		takeWebcamPicture.setBounds(10, 40, 180, 20);
		add (takeWebcamPicture);
		takeWebcamPicture.addActionListener(this);		
		
		downSample = new JButton ("Downsample");
		downSample.setBounds (10, 70, 180, 20);
		add (downSample);
		downSample.addActionListener(this);		
		
		increaseContrast = new JButton ("Increase contrast");
		increaseContrast.setBounds (10, 100, 180, 20);
		add (increaseContrast);
		increaseContrast.addActionListener(this);
		
		decreaseContrast = new JButton ("Decrease contrast");
		decreaseContrast.setBounds (10, 130, 180, 20);
		add (decreaseContrast);
		decreaseContrast.addActionListener(this);		
		
		doFaceDetection = new JButton ("Do face detection");
		doFaceDetection.setBounds(10, 190, 180, 20);
		add (doFaceDetection);
		doFaceDetection.addActionListener(this);
		
		imagePanel = new ImagePanel ();
		imagePanel.setBounds(200, 10, 300, 300);
		imagePanel.setBackground(Color.BLUE);
		add (imagePanel);
		
	} // end constructor

	public void showImage (Image img)
	{
		imagePanel.setImage (img);
		imagePanel.repaint();
	}
	public void setController(MainController controller)
	{
		faceTrackingController = controller;
		faceDetectors = new JList(faceTrackingController.getDetectors().toArray());
		faceDetectors.setBounds(10, 220, 180, 20*faceTrackingController.getDetectors().size());
		add (faceDetectors);
	}
	
	public MainController getController()
	{
		return faceTrackingController;
	}
	
	public File showOpenFileDialog() {
		JFileChooser fileChooser = new JFileChooser("./resources");
		int returnVal = fileChooser.showOpenDialog(this);
		if (returnVal == JFileChooser.APPROVE_OPTION) {
            return fileChooser.getSelectedFile();
		} else {
			return null;
		}
		
	}
	
	public void actionPerformed(ActionEvent event)
	{
		// Check if the "Load static image" button was pressed
		if (event.getSource() == loadImage)
		{
			faceTrackingController.loadImageFromFile();
		}
		// Check if the "Take webcam picture" button was pressed
		else if (event.getSource() == takeWebcamPicture)
		{
			faceTrackingController.takeWebcamPicture();
		}
		// Check if the "Find skin pixels" button was pressed
		else if (event.getSource() == doFaceDetection)
		{
			faceTrackingController.doFaceDetection(faceDetectors.getSelectedIndex());
		}
		// Check if the "Increase contrast" button was pressed
		else if (event.getSource() == increaseContrast)
		{
			faceTrackingController.increaseContrast();
		}
		else if (event.getSource() == decreaseContrast)
		{
			faceTrackingController.decreaseContrast();
		}
		else if (event.getSource() == downSample)
		{
			faceTrackingController.downSample();
		}
	}

}
