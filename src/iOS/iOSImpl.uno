using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Threading;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;

namespace Fuse.BackgroundDownload
{
    // [Require("uContext.SourceFile.DidFinishLaunching", "[self initializeLocalNotifications:[notification object]];")]
    [ForeignInclude(Language.ObjC, "DownloadDelegate.h")]
    [Require("Entity", "BackgroundDownload.RegisterDownload(ulong,ObjC.Object)")]
    [Require("Entity", "BackgroundDownload.RecieveProgress(ulong,ulong,ulong)")]
    [Require("Entity", "BackgroundDownload.RecieveDownloadPaused(ulong,ObjC.Object)")]
    [Require("Entity", "BackgroundDownload.RecieveSuccessfulCompletion(ulong,string)")]
    [Require("Entity", "BackgroundDownload.RecieveErroredCompletion(ulong,string)")]
    internal static extern(iOS) class BackgroundDownload
    {
        static internal ObjC.Object _downloadDelegate;
        static readonly Dictionary<ulong, ObjC.Object> _ongoingDownloads = new Dictionary<ulong, ObjC.Object>();
        static readonly Dictionary<ulong, ObjC.Object> _pausedDownloads = new Dictionary<ulong, ObjC.Object>();

        // We have these as funcs to make interaction with the dictionaries cleaner in the foreign code
        static ObjC.Object IDToOngoing(ulong id) { return _ongoingDownloads[id]; }
        static ObjC.Object IDToPaused(ulong id) { return _pausedDownloads[id]; }

        static readonly ulong UNKNOWN_SIZE = extern<ulong>"(@{ulong})NSURLSessionTransferSizeUnknown";

        // For communication back to the JS Module
        public static event Action<ulong,ulong,ulong> OnProgress;
        public static event Action<ulong> OnPaused;
        public static event Action<ulong, string> OnSucceeded;
        public static event Action<ulong, string> OnFailed;

        // outgoing messages
        [Foreign(Language.ObjC)]
        internal static void Initialize()
        @{
            DownloadDelegate* dd = [[DownloadDelegate alloc] init];
            @{_downloadDelegate:Set(dd)};
            [@{_downloadDelegate} setup];
        @}

        [Foreign(Language.ObjC)]
        internal static ulong StartDownload(string urlStr)
        @{
            return (@{ulong})[@{_downloadDelegate} startDownload:urlStr];
        @}

        [Foreign(Language.ObjC)]
        internal static void StopDownload(ulong downloadID)
        @{
            [@{_downloadDelegate} stopDownload:@{IDToOngoing(ulong):Call(downloadID)}];
        @}

        [Foreign(Language.ObjC)]
        internal static void PauseDownload(ulong downloadID)
        @{
            [@{_downloadDelegate} pauseDownload:@{IDToOngoing(ulong):Call(downloadID)}];
        @}

        [Foreign(Language.ObjC)]
        internal static ulong ResumeDownload(ulong downloadID)
        @{
            return (@{ulong})[@{_downloadDelegate} resumeDownload:@{IDToPaused(ulong):Call(downloadID)}];
        @}

        // incoming messages
        static void RegisterDownload(ulong taskIdentifier, ObjC.Object task)
        {
            _ongoingDownloads[taskIdentifier] = task;
        }

        static void RecieveDownloadPaused(ulong taskIdentifier, ObjC.Object pauseData)
        {
            _pausedDownloads[taskIdentifier] = pauseData;
            _ongoingDownloads.Remove(taskIdentifier);
            var handler = OnPaused;
            if (handler != null)
                handler(taskIdentifier);
        }

        static void RecieveProgress(ulong taskIdentifier, ulong totalBytesWritten, ulong totalBytesExpectedToWrite)
        {
            var handler = OnProgress;
            if (handler != null)
            {
                if (totalBytesExpectedToWrite== UNKNOWN_SIZE)
                    handler(taskIdentifier, totalBytesWritten, totalBytesExpectedToWrite);
                else
                    handler(taskIdentifier, (ulong)-1, (ulong)-1);
            }
        }

        static void RecieveSuccessfulCompletion(ulong taskIdentifier, string finalPath)
        {
            _ongoingDownloads.Remove(taskIdentifier);
            var handler = OnSucceeded;
            if (handler != null)
                handler(taskIdentifier, finalPath);
        }

        static void RecieveErroredCompletion(ulong taskIdentifier, string errorMessage)
        {
            _ongoingDownloads.Remove(taskIdentifier);
            var handler = OnFailed;
            if (handler != null)
                handler(taskIdentifier, errorMessage);
        }
    }
}
