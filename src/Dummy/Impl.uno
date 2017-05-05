using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Threading;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;

namespace Fuse.BackgroundDownload
{
    public static extern(!Mobile) class BackgroundDownload
    {
        public static event Action<ulong,ulong,ulong> OnProgress;
        public static event Action<ulong> OnPaused;
        public static event Action<ulong, string> OnSucceeded;
        public static event Action<ulong, string> OnFailed;

        internal static void Initialize() {}
        internal static void StopDownload(ulong downloadID) {}
        internal static void PauseDownload(ulong downloadID) {}
        internal static ulong StartDownload(string urlStr) { return 0; }
        internal static ulong ResumeDownload(ulong downloadID) { return 0; }
    }
}
