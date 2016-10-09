package com.java.facetracking.model;

import java.awt.Color;
import java.awt.Point;
import java.awt.image.BufferedImage;
import java.util.ArrayList;

public class ColorComparison extends FaceDetector {
	
	public ColorComparison() {
		super("Color Comparison");
	}

	// Given an image, find all the skin pixels and store the x and y coordinates
	// of the pixels in an array list.
	private ArrayList<Point> findSkinPixels(BufferedImage img) {
		ArrayList<Point> skinPixels = new ArrayList<Point>();
		int x, y;
		Color c;
		float[] hsbvals;
				
		// This will need to be replaced with an algorithm to find the real x and y
		// coordinates of skin pixels
		for(x = 0; x < img.getWidth(); x++) {
			for (y = 0; y < img.getHeight(); y++) {
				c = new Color(img.getRGB(x, y));
				hsbvals = Color.RGBtoHSB(c.getRed(), c.getGreen(), c.getBlue(), null);
				// If the pixel is skin coloured, add the x and y coordinates to the list
				/*if (   c.getRed() >= 218 && c.getRed() <= 258
					&& c.getGreen() >= 156 && c.getGreen() <= 216
					&& c.getBlue() >= 197 && c.getBlue() <= 257) {*/
				
				if (   hsbvals[0] >= 0.875 && hsbvals[0] <= 0.958
						&& hsbvals[1] >= 0.10 && hsbvals[1] <= 0.35
						&& hsbvals[2] >= 0.50 && hsbvals[2] <= 0.98) { 
					skinPixels.add(new Point(x, y));				
				}
			}
		}
		
		return skinPixels;
	}
		
	// Given an array list of skin pixels, try to find the center of the face
	private Point findFaceCentre(ArrayList<Point> skinPixels, BufferedImage img) {
		Point centre = new Point();			
		Point mean = new Point(0, 0);
		Point median = new Point(0, 0);
		Point mode = new Point(0, 0);
		int[] countX = new int[img.getWidth()];
		int[] countY = new int[img.getHeight()];
		
		for (int i = 0; i < skinPixels.size(); i++) {
			mean.x += skinPixels.get(i).x;
			mean.y += skinPixels.get(i).y;
			
		}
		if (skinPixels.size() > 0) {
			mean.x /= skinPixels.size();
			mean.y /= skinPixels.size();
		}
		
		return mean;
	}

	@Override
	public DetectedFace processImage(BufferedImage img) 
	{			
		ArrayList<Point> pixels = findSkinPixels(img);
		DetectedFace detectedFace = new DetectedFace(pixels, findFaceCentre(pixels, img));
		
		return detectedFace;

	}
}
