package com.android.heyjane.metadata;

import java.util.Random;

import android.graphics.Bitmap;

public class Metadata {
	public String owner = "";
	public Bitmap ownerImage;
	public int numberOfLikes;
	public String elapsedTime = "";
	public int getNumberOfLikes() 
	{
		return new Random().nextInt(300);
	}
}
