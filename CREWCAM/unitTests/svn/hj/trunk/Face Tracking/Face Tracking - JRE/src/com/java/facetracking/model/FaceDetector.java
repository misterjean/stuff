package com.java.facetracking.model;

import java.awt.image.*;
import java.awt.Color;
import java.awt.Point;
import java.util.ArrayList;

public abstract class FaceDetector
{	
	private String name;
	public FaceDetector(String detectorName)
	{
		name = detectorName;
	}
	
	public abstract DetectedFace processImage(BufferedImage img) throws Exception;
	
	@Override
	public String toString()
	{
		return name;
	}
}
