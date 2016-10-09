package com.java.facetracking.model;

import java.awt.Point;
import java.util.ArrayList;

public class DetectedFace 
{
	public ArrayList<Point> facePoints;
	public Point faceCenter;
	
	public DetectedFace(ArrayList<Point> facePoints, Point faceCenter)
	{
		this.facePoints = facePoints;
		this.faceCenter = faceCenter;
	}
}
