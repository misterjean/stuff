package com.java.facetracking.model;

import java.awt.Image;
import java.awt.image.*;
//import com.googlecode.javacpp.Loader;
import com.googlecode.javacv.*;
//import com.googlecode.javacv.cpp.*;
import static com.googlecode.javacv.cpp.opencv_core.*;
//import static com.googlecode.javacv.cpp.opencv_imgproc.*;
//import static com.googlecode.javacv.cpp.opencv_calib3d.*;
//import static com.googlecode.javacv.cpp.opencv_objdetect.*;

public class WebcamInterface {
	
	// Get a picture from the webcam
	public BufferedImage getWebcamPicture() throws Exception {
		FrameGrabber grabber = new OpenCVFrameGrabber(0);
        grabber.start();

        // FAQ about IplImage:
        // - For custom raw processing of data, getByteBuffer() returns an NIO direct
        //   buffer wrapped around the memory pointed by imageData.
        // - To get a BufferedImage from an IplImage, you may call getBufferedImage().
        // - The createFrom() factory method can construct an IplImage from a BufferedImage.
        // - There are also a few copy*() methods for BufferedImage<->IplImage data transfers.
        IplImage grabbedImage = grabber.grab();
        BufferedImage bufImage = grabbedImage.getBufferedImage();
        int newWidth, newHeight;
        if (bufImage.getWidth() > bufImage.getHeight()) {
        	newWidth = 300;
        	newHeight = 300 * bufImage.getHeight() / bufImage.getWidth();
        } else {
        	newHeight = 300;
        	newWidth = 300 * bufImage.getWidth() / bufImage.getHeight();        	
        }
        Image scaledImage = bufImage.getScaledInstance(newWidth, newHeight, Image.SCALE_DEFAULT);
        
		// Replace this with real code
		return ImageProcessor.toBufferedImage(scaledImage);
	}
}
