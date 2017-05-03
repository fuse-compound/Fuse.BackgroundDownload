#import <Foundation/Foundation.h>

@interface DownloadDelegate : NSObject<NSURLSessionDelegate>
- (void)setup;
- (NSUInteger)startDownload:(NSString*)urlStr;
- (void)stopDownload:(NSURLSessionDownloadTask*)task;
- (void)pauseDownload:(NSURLSessionDownloadTask*)task;
- (NSUInteger)resumeDownload:(NSData*)resumeData;
@end
