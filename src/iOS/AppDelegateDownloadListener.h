#pragma once

#ifdef __OBJC__
#include <Uno-iOS/AppDelegate.h>
#include <Uno-iOS/Uno-iOS.h>

@interface uAppDelegate (AppDelegateDownloadListener)

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@end

#endif
