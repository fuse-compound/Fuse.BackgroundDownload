var Observable = require("FuseJS/Observable");
var Downloader = require("FuseJS/BackgroundDownload");

var lastDownloadID = -1;
var info = Observable("");

var startDownload = function() {
    console.log("Starting");
    lastDownloadID = Downloader.start("http://download.thinkbroadband.com/20MB.zip");
    console.log("Started " + lastDownloadID);
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

Downloader.on("succeeded", function(downloadID, finalPath) {
    console.log("success! - " + downloadID + ": " + finalPath);
});

Downloader.on("failed", function(downloadID, errorMessage) {
    console.log("failure :( - " + downloadID + ": " + errorMessage);
});

module.exports = {
    startDownload: startDownload,
    stopDownload: stopDownload,
    pauseDownload: pauseDownload,
    resumeDownload: resumeDownload,
    info: info
};
