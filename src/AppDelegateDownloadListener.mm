#include <Uno/Uno.h>

#include <ObjC.Object.h>
#import <objc/runtime.h>

#include <AppDelegateDownloadListener.h>

static void* backgroundTransferCompletionHandlerKey = &backgroundTransferCompletionHandlerKey;

@implementation uAppDelegate (AppDelegateDownloadListener)

- (void(^)())backgroundTransferCompletionHandler
{
    return objc_getAssociatedObject(self, backgroundTransferCompletionHandlerKey);
}

- (void)setBackgroundTransferCompletionHandler:(void(^)())handler
{
    objc_setAssociatedObject(self, backgroundTransferCompletionHandlerKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // And some logic goes here
    // if app is not running we can't use the original session, so we need to make a new one with
    // the exact same config as the original one and then use that session object.
    // This is only needed IF we want to perform some logic involving the session object. If we are just
    // waiting on a download to finish then we can wait for `didFinishDownloadingToURL` to be fired as that
    // will be given a valid session object. However we do want to cache the completionHandler.
    //
    // The completion handler is called (by us) to tell the system that we are done changing the UI and it
    // can take a new snapshot
    //
    // So when we are in the background or closed this will be called first. By caching the completionHandler
    // we are able to tell from other methods if we are within the 'scope' of a wakeup.
    //
    // Sometime after a wakeup `URLSessionDidFinishEventsForBackgroundURLSession` will get called. That is where
    // we will call the completion handler.

    self.backgroundTransferCompletionHandler = completionHandler;
}

@end
