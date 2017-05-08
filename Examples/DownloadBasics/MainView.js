var Observable = require("FuseJS/Observable");
var Downloader = require("FuseJS/BackgroundDownload");

var lastDownloadID = -1;
var info = Observable("");

var startDownload = function() {
    console.log("Fcukeroo");
    // lastDownloadID = Downloader.start("http://i.imgur.com/F49TZOI.gif");
    lastDownloadID = Downloader.start("http://download.thinkbroadband.com/20MB.zip");
    // lastDownloadID = Downloader.start("http://download.thinkbroadband.com/100MB.zip");
    console.log("Fcukeroo'd " + lastDownloadID);
};

var stopDownload = function() {
    console.log("stop called: " + lastDownloadID);
    Downloader.stop(lastDownloadID);
};

var pauseDownload = function() {
    console.log("pause called: " + lastDownloadID);
    Downloader.pause(lastDownloadID);
};

var resumeDownload = function() {
    console.log("resume called: " + lastDownloadID);
    lastDownloadID = Downloader.resume(lastDownloadID);
};

Downloader.on("progress", function(downloadID, bytesSoFar, totalBytesExpected) {
    console.log("Rock on " + downloadID + ": " + bytesSoFar/totalBytesExpected);
});

Downloader.on("paused", function(kind, downloadID) {
    console.log(kind + " - " + downloadID);
});

Downloader.on("succeeded", function(kind, downloadID, finalPath) {
    console.log(kind + " - " + downloadID + ": " + finalPath);
});

Downloader.on("failed", function(kind, downloadID, errorMessage) {
    console.log(kind + " - " + downloadID + ": " + errorMessage);
});

module.exports = {
    startDownload: startDownload,
    stopDownload: stopDownload,
    pauseDownload: pauseDownload,
    resumeDownload: resumeDownload,
    info: info
};
