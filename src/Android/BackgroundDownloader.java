package com.fuse.BackgroundDownload;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.SparseArray;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class BackgroundDownloader
{
    // Pool Settings
    private static final int CORE_POOL_SIZE = 8;
    private static final int MAXIMUM_POOL_SIZE = 8;
    private static final int KEEP_ALIVE_TIME = 1000;

    // Message Codes
    static final int SUCCESS = 0;
    static final int FAILED = 1;
    static final int PAUSED = 2;
    static final int STOPPED = 3;
    static final int PROGRESS = 4;

    // Thread Pool & Messaging
    private static ThreadPoolExecutor _downloadThreadPool;
    private static final BlockingQueue<Runnable> _downloadWorkQueue = new LinkedBlockingQueue<Runnable>();
    private static Handler _handler;

    private static Object _syncObj = new Object();
    static Object GetSyncObject() { return _syncObj; } // internal so it can be used by downloads

    // DownloadRunnable Caches
    private static final SparseArray<DownloadRunnable> _ongoingDownloads = new SparseArray<DownloadRunnable>();
    private static final SparseArray<PausedDownload> _pausedDownloads= new SparseArray<PausedDownload>();
    private static int _lastID = 0;

    // Callbacks to Uno
    private static com.foreign.Uno.Action_int_int_int _onProgress;
    private static com.foreign.Uno.Action_int_String _onSucceeded;
    private static com.foreign.Uno.Action_int_String _onFailed;
    private static com.foreign.Uno.Action_int _onPaused;

    // Kick off the whole show.
    static
    {
        _downloadThreadPool = new ThreadPoolExecutor(
                CORE_POOL_SIZE,
                MAXIMUM_POOL_SIZE,
                KEEP_ALIVE_TIME,
                TimeUnit.MILLISECONDS,
                _downloadWorkQueue);

        // This becomes attached to the UI thread
        _handler = new Handler(Looper.getMainLooper())
        {
            @Override public void handleMessage(Message inputMessage)
            {
                ReceiveMessage(inputMessage.what, inputMessage.obj);
            }
        };
    }


    public static void Init(final com.foreign.Uno.Action_int_int_int onProgress,
                            final com.foreign.Uno.Action_int_String onSucceeded,
                            final com.foreign.Uno.Action_int_String onFailed,
                            final com.foreign.Uno.Action_int onPaused)
    {
        _onProgress = onProgress;
        _onSucceeded = onSucceeded;
        _onFailed = onFailed;
        _onPaused = onPaused;
    }

    public static int StartDownload(String url)
    {
        int id = _lastID += 1;
        DownloadRunnable downloadTask = new DownloadRunnable(id, _handler, url);
        _ongoingDownloads.put(id, downloadTask);
        _downloadThreadPool.execute(downloadTask);
        return id;
    }

    public static void ResumeDownload(int id)
    {
        PausedDownload paused = _pausedDownloads.get(id);
        _pausedDownloads.remove(id);
        DownloadRunnable downloadTask = new DownloadRunnable(id, _handler, paused);
        _ongoingDownloads.put(id, downloadTask);
        _downloadThreadPool.execute(downloadTask);
    }

    public static void PauseDownload(int id)
    {
        DownloadRunnable download = _ongoingDownloads.get(id);
        download.Pause();
    }

    public static void StopDownload(int id)
    {
        DownloadRunnable download = _ongoingDownloads.get(id);
        download.Stop();
    }

    // Messages arriving from the ongoing downloads
    private static void ReceiveMessage(int messageKind, Object obj)
    {
        switch (messageKind)
        {
            case SUCCESS:
            {
                CompleteDownload download = (CompleteDownload) obj;
                _ongoingDownloads.remove(download.ID);
                _onSucceeded.run(download.ID, download.Path);
                break;
            }
            case FAILED:
            {
                DownloadRunnable download = (DownloadRunnable)obj;
                _ongoingDownloads.remove(download.ID);
                _onFailed.run(download.ID, download.PendingException.getLocalizedMessage());
                break;
            }
            case PAUSED:
            {
                PausedDownload paused = (PausedDownload)obj;
                _ongoingDownloads.remove(paused.ID);
                _pausedDownloads.put(paused.ID, paused);
                _onPaused.run(paused.ID);
                break;
            }
            case STOPPED:
            {
                DownloadRunnable download = (DownloadRunnable)obj;
                _ongoingDownloads.remove(download.ID);
                // we don't actually report this in iOS
                break;
            }
            case PROGRESS:
            {
                ProgressData data = (ProgressData)obj;
                _onProgress.run(data.ID, data.BytesDownloadedSoFar, data.ExpectedSizeOfFile);
                break;
            }
        }
    }
}
