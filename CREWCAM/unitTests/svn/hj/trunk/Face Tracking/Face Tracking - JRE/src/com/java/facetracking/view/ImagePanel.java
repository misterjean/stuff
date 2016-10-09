package com.java.facetracking.view;

import java.awt.*;

import javax.swing.JPanel;

public class ImagePanel extends JPanel 

{
	private Image img = null;

	public Image getImage ()
	{
		return img;
	}
	
	public void setImage (Image setImage)
	{
		img = setImage;
	}
	
	public void paintComponent(Graphics g) 
	{
		super.paintComponent(g);
		
		if (img != null)
		{
			g.drawImage(img, 0, 0, null);
		}
	}
}