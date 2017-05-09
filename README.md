# Fuse.BackgroundDownloader

This simple library download files in a way that allows the download to progress even when the app is in the background.

When you start a download you are given an ID, all the rest of the calls between the background downloader and your code will include the ID.

## Including the library

To use the downloader in your app you first add a reference to it from your `unoproj` file. For an example see `Examples/DownloadBasics/DownloadBasics.unoproj`[./Examples/DownloadBasics/DownloadBasics.unoproj]

Next you `require` it from your javascript code.

```
var Downloader = require("FuseJS/BackgroundDownload");
```

And now you are ready to go.

## How you communicate with the Downloader

### Starting a download

To start a download call the `start` function with the url of the file you wish to download:

```
downloadID = Downloader.start("http://download.thinkbroadband.com/20MB.zip");
```

Keep the ID so you can track and control this download as it progresses.

### Pausing a download

Sometimes you want to stop a download temporarily without losing your progress, `pause` is what you need here:

```
Downloader.pause(lastDownloadID);
```

The download will stay paused until it is resumed or the app quits, in which case the download is lost.

### Resume a download

If you want to continue a download that you have previously paused then you can do the following:

```
newDownloadID = Downloader.resume(lastDownloadID);
```

Please remember to store the ID for you download. It is possible that the new ID may be the same as the old ID but this is not guaranteed and should never be assumed.

### Stopping a download

Simply call `stop` with the ID you were given by the `start` or `resume` function.

```
Downloader.stop(lastDownloadID);
```

## How the Downloader communicates with you

During the course of the download events will be fired that you can subscribe to.

### The 'progress' event

This is called during a download to inform you how the download is progressing. You are given the download ID, the number of bytes downloaded so far and the total number of bytes expected to be downloaded.

These last two values may be `-1` if the true size is not known.

```
Downloader.on("progress", function(downloadID, bytesSoFar, totalBytesExpected) {
    console.log("Rock on " + downloadID + ": " + (bytesSoFar / totalBytesExpected));
});
```

### The 'paused' event

When you pause a download the call is made asynchronously, when it succeeds this event will be called with the ID of the download that has been paused.

```
Downloader.on("paused", function(kind, downloadID) {
    console.log(kind + " - " + downloadID);
});
```

### The 'succeeded' event

This event is fired when your download finished successfully. It passed you the filepath to the downloaded file. Your files are saved to your app's private storage so you may wish to move this file once the download is completed. This copying is outside the scope of this library but Fuse provides functions for doing that.

```
Downloader.on("succeeded", function(kind, downloadID, finalPath) {
    console.log(kind + " - " + downloadID + ": " + finalPath);
});
```

### The 'failed' event

This event is fired when your download finished unsuccessfully. It passes you a platform specific error message.

```
Downloader.on("failed", function(kind, downloadID, errorMessage) {
    console.log(kind + " - " + downloadID + ": " + errorMessage);
});
```

## That's all folks

I hope people find this library useful. It's an open source project under the MIT license and pull requests are very welcome.
