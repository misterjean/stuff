package com.android.heyjane.io.transmit;

public class RTPEncoder 
{
	private static int RTP_HEADER_LENGTH = 12;
	private static byte RTP_HDR_B1 = 1; // really cheating.
	private static byte RTP_HDR_B2 = 0x0f; // really cheating.
	
	// Memory needs to be freed by the caller.
	public static byte [] encodeData(byte [] data, int length, long sIdentifier, int sequenceNumber)
	{
		byte [] rtpData = new byte [length + RTP_HEADER_LENGTH];
		
		rtpData[0] = RTP_HDR_B1;
		rtpData[1] = RTP_HDR_B2;
		
		byte [] seqNum = RTPEncoder.shortToByteArray(sequenceNumber);
		byte [] ssrc = RTPEncoder.intToByteArray(sIdentifier);
		
		System.arraycopy(seqNum, 0, rtpData, 2, 2);
		System.arraycopy(ssrc, 0, rtpData, 4, 4);
		
		if (length != 0) //eof data
		{
			//copy data to be encoded.
			System.arraycopy(data, 0, rtpData, RTP_HEADER_LENGTH, length);
		}
		
		return rtpData;
	}
	
	public static byte[] shortToByteArray(int value) 
	{
	    return new byte[] {
	            (byte)(value >>> 8),
	            (byte)value};
	}
	
	public static byte[] intToByteArray(long value) 
	{
	    return new byte[] {
	            (byte)(value >>> 24),
	            (byte)(value >>> 16),
	            (byte)(value >>> 8),
	            (byte)value};
	}

	public static int getHeaderSize() {
		return RTP_HEADER_LENGTH;
	}
		
}