using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Threading;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;

namespace Fuse.BackgroundDownload
{
    [UXGlobalModule]
    public sealed class BackgroundDownloadModule : NativeEventEmitterModule
    {
        static readonly BackgroundDownloadModule _instance;

        public BackgroundDownloadModule() : base(false, "paused", "succeeded", "failed", "progress")
        {
            if(_instance != null) return;
            Resource.SetGlobalKey(_instance = this, "FuseJS/BackgroundDownload");

            BackgroundDownload.Initialize();
            BackgroundDownload.OnProgress += OnProgress;
            BackgroundDownload.OnPaused += OnPaused;
            BackgroundDownload.OnSucceeded += OnSucceeded;
            BackgroundDownload.OnFailed += OnFailed;

            // Old-style events for backwards compatibility
            var onProgressEvent = new NativeEvent("onProgress");
            On("progress", onProgressEvent);
            AddMember(onProgressEvent);

            var onPausedEvent = new NativeEvent("onPaused");
            On("paused", onPausedEvent);
            AddMember(onPausedEvent);

            var onSucceededEvent = new NativeEvent("onSucceeded");
            On("succeeded", onSucceededEvent);
            AddMember(onSucceededEvent);

            var onFailedEvent = new NativeEvent("onFailed");
            On("failed", onFailedEvent);
            AddMember(onFailedEvent);

            AddMember(new NativeFunction("start", (NativeCallback)Start));
            AddMember(new NativeFunction("stop", (NativeCallback)Stop));
            AddMember(new NativeFunction("pause", (NativeCallback)Pause));
            AddMember(new NativeFunction("resume", (NativeCallback)Resume));
        }

        static object Start(Context c, object[] args)
        {
            return BackgroundDownload.StartDownload((string)args[0]).ToString();
        }

        object Stop(Context c, object[] args)
        {
            ulong id = 0;
            if (ULong.TryParse((string)args[0], out id))
                BackgroundDownload.StopDownload(id);
            return null;
        }

        object Pause(Context c, object[] args)
        {
            ulong id = 0;
            if (ULong.TryParse((string)args[0], out id))
                BackgroundDownload.PauseDownload(id);
            return null;
        }

        object Resume(Context c, object[] args)
        {
            ulong id = 0;
            if (ULong.TryParse((string)args[0], out id))
                return BackgroundDownload.ResumeDownload(id).ToString();;
            return null;
        }

        // feedback
        void OnProgress(ulong taskIdentifier, ulong totalBytesWritten, ulong totalBytesExpectedToWrite)
        {
            Emit(new object[] { "progress", taskIdentifier.ToString(), (double)totalBytesWritten, (double)totalBytesExpectedToWrite });
        }

        void OnPaused(ulong taskIdentifier)
        {
            Emit(new object[] { "paused", taskIdentifier.ToString() });
        }

        void OnSucceeded(ulong taskIdentifier, string finalPath)
        {
            Emit(new object[] { "succeeded", taskIdentifier.ToString(), finalPath });
        }

        void OnFailed(ulong taskIdentifier, string errorMsg)
        {
            Emit(new object[] { "failed", taskIdentifier.ToString(), errorMsg });
        }
    }
}
