using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Threading;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Uno.Compiler.ExportTargetInterop.Android;
using Fuse.Scripting;

namespace Fuse.BackgroundDownload
{
    [Require("Entity", "BackgroundDownload.RecieveDownloadPaused(int)")]
    [Require("Entity", "BackgroundDownload.RecieveProgress(int,int,int)")]
    [Require("Entity", "BackgroundDownload.RecieveSuccessfulCompletion(int,string)")]
    [Require("Entity", "BackgroundDownload.RecieveErroredCompletion(int,string)")]
    internal static extern(Android) class BackgroundDownload
    {
        // For communication back to the JS Module
        public static event Action<ulong,ulong,ulong> OnProgress;
        public static event Action<ulong> OnPaused;
        public static event Action<ulong, string> OnSucceeded;
        public static event Action<ulong, string> OnFailed;

        // outgoing messages
        internal static void Initialize()
        {
            InitInner(RecieveProgress,
                      RecieveSuccessfulCompletion,
                      RecieveErroredCompletion,
                      RecieveDownloadPaused);
        }

        [Foreign(Language.Java)]
        static void InitInner(Action<int,int,int> onProgress,
                              Action<int, string> onSucceeded,
                              Action<int, string> onFailed,
                              Action<int> onPaused)
        @{
            com.fuse.BackgroundDownload.BackgroundDownloader.Init(onProgress, onSucceeded, onFailed, onPaused);
        @}

        internal static ulong StartDownload(string urlStr)
        {
            return (ulong)StartDownloadInner(urlStr);
        }

        [Foreign(Language.Java)]
        static int StartDownloadInner(string urlStr)
        @{
            return com.fuse.BackgroundDownload.BackgroundDownloader.StartDownload(urlStr);
        @}

        internal static void StopDownload(ulong downloadID)
        {
            StopDownloadInner((int)downloadID);
        }

        [Foreign(Language.Java)]
        static void StopDownloadInner(int downloadID)
        @{
            com.fuse.BackgroundDownload.BackgroundDownloader.StopDownload(downloadID);
        @}

        internal static void PauseDownload(ulong downloadID)
        {
            PauseDownloadInner((int)downloadID);
        }

        [Foreign(Language.Java)]
        static void PauseDownloadInner(int downloadID)
        @{
            com.fuse.BackgroundDownload.BackgroundDownloader.PauseDownload(downloadID);
        @}

        internal static ulong ResumeDownload(ulong downloadID)
        {
            return (ulong)ResumeDownloadInner((int)downloadID);
        }

        [Foreign(Language.Java)]
        static int ResumeDownloadInner(int downloadID)
        @{
            com.fuse.BackgroundDownload.BackgroundDownloader.ResumeDownload(downloadID);
            return downloadID;
        @}


        [ForeignFixedName]
        static void RecieveDownloadPaused(int taskIdentifier)
        {
            var handler = OnPaused;
            if (handler != null)
                handler((ulong)taskIdentifier);
        }

        [ForeignFixedName]
        static void RecieveProgress(int taskIdentifier, int totalBytesWritten, int totalBytesExpectedToWrite)
        {
            var handler = OnProgress;
            if (handler != null)
                handler((ulong)taskIdentifier, (ulong)totalBytesWritten, (ulong)totalBytesExpectedToWrite);
        }

        [ForeignFixedName]
        static void RecieveSuccessfulCompletion(int taskIdentifier, string finalPath)
        {
            var handler = OnSucceeded;
            if (handler != null)
                handler((ulong)taskIdentifier, finalPath);
        }

        [ForeignFixedName]
        static void RecieveErroredCompletion(int taskIdentifier, string errorMessage)
        {
            var handler = OnFailed;
            if (handler != null)
                handler((ulong)taskIdentifier, errorMessage);
        }
    }
}
