package com.fuse.BackgroundDownload;

import java.io.File;
import java.net.URL;

public class PausedDownload
{
    public final int ID;
    public final java.net.URL URL;
    public final File PartialFile;

    public PausedDownload(int id, URL url, File partialFile)
    {
        ID = id;
        URL = url;
        PartialFile = partialFile;
    }
}
