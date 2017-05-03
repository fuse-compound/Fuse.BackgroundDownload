package com.fuse.BackgroundDownload;

public class ProgressData {

    public final int ID;
    public final int ExpectedSizeOfFile;
    public final int BytesDownloadedSoFar;

    public ProgressData(int id, int expectedSizeOfFile, int bytesSoFar)
    {
        ID = id;
        ExpectedSizeOfFile = expectedSizeOfFile;
        BytesDownloadedSoFar = bytesSoFar;
    }
}
