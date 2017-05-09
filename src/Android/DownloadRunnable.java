package com.fuse.BackgroundDownload;

import android.os.Handler;
import android.os.Message;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.concurrent.ConcurrentLinkedQueue;

public class DownloadRunnable implements Runnable
{
    // constants
    private static final int CONTINUE = -1;
    private static final int STOP = 0;
    private static final int PAUSE = 1;

    // can be accessed by multiple threads
    private ConcurrentLinkedQueue<Integer> _inboundQueue = new ConcurrentLinkedQueue<Integer>();
    private Thread _downloadingThread;
    public final int ID;
    public Exception PendingException;

    // Local to the thread
    private Handler _handler;
    private URL _url;
    private File _outputFile;

    public DownloadRunnable(final int id, final Handler handler, final String url)
    {
        ID = id;
        _handler = handler;
        try
        {
            _url = new URL(url);
        }
        catch (MalformedURLException e)
        {
            SignalFailure(e);
        }
    }

    public DownloadRunnable(final int id, final Handler handler, final PausedDownload paused)
    {
        ID = id;
        _handler = handler;
        _outputFile = paused.PartialFile;
        _url = paused.URL;
    }

    public void run()
    {
        synchronized(BackgroundDownloader.GetSyncObject())
        {
            _downloadingThread = Thread.currentThread();
        }

        if (PendingException != null)
            return;

        try
        {
            Download();
        }
        catch (Exception e)
        {
            SignalFailure(e);
        }
    }

    private void Download() throws Exception
    {
        long downloadFromByte = 0;
        int lengthOfFile = 0;
        FileOutputStream outputStream;
        Runnable outTask = null;

        if (_outputFile == null)
        {
            // new download
            File outputDir = com.fuse.Activity.getRootActivity().getCacheDir();
            _outputFile = File.createTempFile("prefix", "extension", outputDir);
            outputStream = new FileOutputStream(_outputFile);
        }
        else
        {
            // resume download
            downloadFromByte = _outputFile.length();
            lengthOfFile = (int)downloadFromByte;
            outputStream = new FileOutputStream(_outputFile, true);
        }


        try
        {
            URLConnection connection = _url.openConnection();

            if (downloadFromByte>0)
                connection.setRequestProperty("Range", "bytes=" + downloadFromByte + "-");

            connection.connect();
            lengthOfFile += connection.getContentLength(); // getContentLength is lower if we have already partially downloaded the file

            InputStream inputStream = new BufferedInputStream(_url.openStream(), 32*1024);

            try
            {
                int bytesReadThisIteration;
                int bytesReadTotal = (int)downloadFromByte;
                int progressThreshold = 100*1024;
                int nextProgress = bytesReadTotal + progressThreshold;
                byte[] data = new byte[16*1024];

                // Check we haven't been interrupted before we get into the meat of this
                if (Thread.interrupted()) return;

                while ((bytesReadThisIteration = inputStream.read(data)) != -1)
                {
                    bytesReadTotal += bytesReadThisIteration;

                    // Write out the data and send progress to listeners
                    if (bytesReadTotal > nextProgress)
                    {
                        SignalProgress(lengthOfFile, bytesReadTotal);
                        nextProgress += progressThreshold;
                    }
                    outputStream.write(data, 0, bytesReadThisIteration);

                    final int inbound = HandleInboundRequests();
                    if (inbound != CONTINUE)
                    {
                        outputStream.flush();
                        outTask = new Runnable()
                        {
                            @Override public void run()
                            {
                                if (inbound!=PAUSE)
                                    TryDeletingFile();
                            }
                        };
                        return;
                    }
                }
                outputStream.flush();
                SignalSuccess();
            }
            finally
            {
                inputStream.close();
            }
        }
        finally
        {
            outputStream.close();
            if (outTask!=null)
                outTask.run();
        }
    }

    private void TryDeletingFile()
    {
        if (_outputFile.exists())
            _outputFile.delete();
    }

    private int HandleInboundRequests() throws Exception
    {
        Integer request = _inboundQueue.poll();

        if (request == null)
        {
            return CONTINUE;
        }
        else if (request == PAUSE)
        {
            SignalPaused();
            return PAUSE;
        }
        else if (request == STOP)
        {
            SignalStopped();
            return STOP;
        }
        else
        {
            throw new Exception("Invalid message sent to ongoing download");
        }
    }

    private void SignalProgress(int totalExpected, int totalSoFar)
    {
        ProgressData data = new ProgressData(ID, totalExpected, totalSoFar);
        Message completeMessage = _handler.obtainMessage(BackgroundDownloader.PROGRESS, data);
        completeMessage.sendToTarget();
    }

    private void SignalPaused()
    {
        PausedDownload paused = new PausedDownload(ID, _url, _outputFile);
        Message completeMessage = _handler.obtainMessage(BackgroundDownloader.PAUSED, paused);
        completeMessage.sendToTarget();
    }

    private void SignalStopped()
    {
        Message completeMessage = _handler.obtainMessage(BackgroundDownloader.STOPPED, this);
        completeMessage.sendToTarget();
    }

    private void SignalFailure(Exception e)
    {
        PendingException = e;
        Message completeMessage = _handler.obtainMessage(BackgroundDownloader.FAILED, this);
        completeMessage.sendToTarget();
    }

    private void SignalSuccess()
    {
        CompleteDownload download = new CompleteDownload(ID, _outputFile.getPath());
        Message completeMessage = _handler.obtainMessage(BackgroundDownloader.SUCCESS, download);
        completeMessage.sendToTarget();
    }


    // These can be called from any thread to send a message to the download thread
    public void Pause()
    {
        _inboundQueue.add(PAUSE);
    }

    public void Stop()
    {
        _inboundQueue.add(STOP);
    }

    public void Terminate()
    {
        synchronized (BackgroundDownloader.GetSyncObject())
        {
            _downloadingThread.interrupt();
        }
    }
}
