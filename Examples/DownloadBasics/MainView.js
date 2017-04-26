var Observable = require("FuseJS/Observable");
var Downloader = require("FuseJS/BackgroundDownload");

var downloadID = -1;
var info = Observable("");

var startDownload = function() {
	console.log("Fcukeroo");
	downloadID = Downloader.start("http://i.imgur.com/F49TZOI.gif");
	console.log("Fcukeroo'd " + downloadID);
};

Downloader.on("progress", function(downloadID, bytesSoFar, totalBytesExpected) {
	console.log("Rock on " + downloadID + ": " + bytesSoFar/totalBytesExpected);
});

Downloader.on("changed", function(kind, downloadID) {
	var args = Array.prototype.slice.call(arguments);
	console.log(kind + " - " + downloadID + ": " + args);
});

module.exports = {
	startDownload: startDownload,
	info: info
};
