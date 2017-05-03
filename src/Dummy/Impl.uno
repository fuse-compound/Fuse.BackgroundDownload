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
        internal static void Initialize() {}
        internal static void StartDownload(string urlStr) {}
    }
}
