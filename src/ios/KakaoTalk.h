#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface KakaoTalk : CDVPlugin
- (void) share:(CDVInvokedUrlCommand*)command;
- (void) shareText:(CDVInvokedUrlCommand*)command;
- (void) shareStory:(CDVInvokedUrlCommand*)command;
@end


