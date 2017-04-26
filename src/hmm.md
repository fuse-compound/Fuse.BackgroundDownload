# Background Download


DownloadManager

- session
- map<Downloads>

- new download: url
- resume download: resumeIdentifier

- add progress listener: listen based on taskIdentifier
  always need a finished listener...or maybe just a event?

- cancel
- cancelWithResume

always downloaded to some temporary place, how to move it? Ah leave that to the filesystem api

Maybe this can just be dirt simple. Only work with IDS

startDownload takes URL and gives downloadID
events arrive with downloadIDs and info
you can cancelWithResumeID taking a downloadID & returning a resumeID
you can cancel taking a downloadID
resumeDownload takes a resumeID and gives a downloadID

events are:

progressEvent:
- downloadID
- bytesSoFar
- expectedSizeInBytes

finishedEvent:
- downloadID
- error
- filename
- filepath

maybe if we see an finishedWithError for an ID we know we have cancelled we should just swallow the error. I dont see this helping the user otherwise
