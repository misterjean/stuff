package com.android.heyjane.io.receive;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;


public class RTPDecoder 
{
	private static int RTP_HEADER_LENGTH = 12;
	private PacketProcessor streamReceiver;
	
	public RTPDecoder(PacketProcessor sr)
	{
		streamReceiver = sr;
	}
	
	public static byte[] copyOfRange(byte[] original, int from, int to) {
	    int newLength = to - from;
	    if (newLength < 0)
	        throw new IllegalArgumentException(from + " > " + to);
	    byte[] copy = new byte[newLength];
	    System.arraycopy(original, from, copy, 0,
	                     Math.min(original.length - from, newLength));
	    return copy;
	}
	
	public RecievingFileProgress receiveData(byte [] data, int length)
	{
		//cheating not decoding version and other stuff.
		int ssrc = 0;
		int sequenceNumber;
				
		ByteBuffer bb = ByteBuffer.allocate(2);
		bb.order(ByteOrder.BIG_ENDIAN);
		
		//extract sequence number
		bb.put(data,2,2);
		sequenceNumber = bb.getShort(0);
		
		//extract ssrc
		bb = ByteBuffer.allocate(4);
		bb.order(ByteOrder.BIG_ENDIAN);
		bb.put(data,4,4);
		ssrc = bb.getInt(0);
		
		//decode data
		return streamReceiver.receiveData(ssrc, sequenceNumber, copyOfRange(data,RTP_HEADER_LENGTH,length),length - RTP_HEADER_LENGTH);
	}
	
}



