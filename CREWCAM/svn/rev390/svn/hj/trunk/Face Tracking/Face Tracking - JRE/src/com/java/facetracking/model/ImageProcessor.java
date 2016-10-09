package com.java.facetracking.model;

import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.ImageIcon;

public final class ImageProcessor {
	
	public static BufferedImage SetContrast(BufferedImage img, int contrastAdjustment)
	{
		int x, y;
		for(x = 0; x < img.getWidth(); x++) {
			for (y = 0; y < img.getHeight(); y++) {
				
				int i = 0;
				
				Color c = new Color(img.getRGB(x, y));
				
				while(i != contrastAdjustment)
				{
					// Update our iterator
					if (contrastAdjustment > 0)
					{
						i++;
					}
					else
					{
						i--;
					}
					
					// Is the average brightness of this pixel greater than 50%?
					if (((c.getBlue() + c.getRed() + c.getGreen())/3) > 128)
					{
						// This is a bright color
						if (contrastAdjustment > 0)
						{
							// We are trying to add contrast
							c = c.brighter();
						}
						else
						{
							// We are trying to lower contrast
							c = c.darker();
						}				
					}
					else
					{
						// This is a dark color
						if (contrastAdjustment > 0)
						{
							// We are trying to add contrast
							c = c.darker();							
						}
						else
						{
							// We are trying to lower contrast
							c = c.brighter();
						}
					}
				}
				
				img.setRGB(x, y, c.getRGB());				
			}
		}
		return img;
	}
	
	public static BufferedImage downsample(BufferedImage img, int downSampleRate)
	{
		int x, y;
		for(x = 0; x < img.getWidth(); x += downSampleRate) {
			for (y = 0; y < img.getHeight(); y += downSampleRate) 
			{
				Color pixelColor;
				
				int redValue = 0;
				int blueValue = 0;
				int greenValue = 0;
				int alphaValue = 0;
				
				for (int pixelOffsetX = 0; pixelOffsetX < downSampleRate; pixelOffsetX++)
				{
					for (int pixelOffsetY = 0; pixelOffsetY < downSampleRate; pixelOffsetY++)
					{
						Color thisColor = new Color(img.getRGB(x + pixelOffsetX, y + pixelOffsetY));
						redValue += thisColor.getRed();
						blueValue += thisColor.getBlue();
						greenValue += thisColor.getGreen();
						alphaValue += thisColor.getAlpha();
					}
				}
			
				redValue /= downSampleRate*downSampleRate;
				blueValue /= downSampleRate*downSampleRate;
				greenValue /= downSampleRate*downSampleRate;
				alphaValue /= downSampleRate*downSampleRate;
				
				pixelColor = new Color(redValue, greenValue, blueValue, alphaValue);
				
				// Set the RGB for each of the pixels we're sampling
				for (int pixelOffsetX = 0; pixelOffsetX < downSampleRate; pixelOffsetX++)
				{
					for (int pixelOffsetY = 0; pixelOffsetY < downSampleRate; pixelOffsetY++)
					{
						img.setRGB(x + pixelOffsetX, y + pixelOffsetY, pixelColor.getRGB());
					}
				}
			}
		}
		return img;
	}

	// This method returns a buffered image with the contents of an image
	public static BufferedImage toBufferedImage(Image image) {
	    if (image instanceof BufferedImage) {
	        return (BufferedImage)image;
	    }

	    // This code ensures that all the pixels in the image are loaded
	    image = new ImageIcon(image).getImage();

	    // Determine if the image has transparent pixels; for this method's
	    // implementation, see Determining If an Image Has Transparent Pixels
	    boolean hasAlpha = false; //hasAlpha(image);

	    // Create a buffered image with a format that's compatible with the screen
	    BufferedImage bimage = null;
	    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
	    try {
	        // Determine the type of transparency of the new buffered image
	        int transparency = Transparency.OPAQUE;
	        if (hasAlpha) {
	            transparency = Transparency.BITMASK;
	        }

	        // Create the buffered image
	        GraphicsDevice gs = ge.getDefaultScreenDevice();
	        GraphicsConfiguration gc = gs.getDefaultConfiguration();
	        bimage = gc.createCompatibleImage(
	            image.getWidth(null), image.getHeight(null), transparency);
	    } catch (HeadlessException e) {
	        // The system does not have a screen
	    }

	    if (bimage == null) {
	        // Create a buffered image using the default color model
	        int type = BufferedImage.TYPE_INT_RGB;
	        if (hasAlpha) {
	            type = BufferedImage.TYPE_INT_ARGB;
	        }
	        bimage = new BufferedImage(image.getWidth(null), image.getHeight(null), type);
	    }

	    // Copy image to buffered image
	    Graphics g = bimage.createGraphics();

	    // Paint the image onto the buffered image
	    g.drawImage(image, 0, 0, null);
	    g.dispose();

	    return bimage;
	}
}
