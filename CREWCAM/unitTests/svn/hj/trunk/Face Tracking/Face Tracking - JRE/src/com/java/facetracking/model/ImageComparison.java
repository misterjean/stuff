package com.java.facetracking.model;

import java.awt.image.BufferedImage;
import java.rmi.UnexpectedException;

public class ImageComparison extends FaceDetector {

	public ImageComparison() {
		super("Image Comparison");
	}

	@Override
	public DetectedFace processImage(BufferedImage img) throws Exception 
	{
		throw new UnexpectedException("Unimplemented");
	}

}
