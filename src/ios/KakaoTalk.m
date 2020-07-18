#import "KakaoLink/KakaoLink.h"

#import "KakaoTalk.h"

#import "StoryLinkHelper.h"

#import "StoryPostingActivity.h"

#import <Cordova/CDVPlugin.h>



@implementation KakaoTalk



- (void)shareText:(CDVInvokedUrlCommand *)command

{

    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];



    KLKTemplate *template = [KLKTextTemplate textTemplateWithBuilderBlock:^(KLKTextTemplateBuilder * _Nonnull textTemplateBuilder) {



        NSString* title = options[@"title"];

        NSString* desc = options[@"desc"];

        NSString* link = options[@"link"];



        textTemplateBuilder.text = [NSString stringWithFormat:@"[%@] - %@",title,desc];

        textTemplateBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {

            linkBuilder.mobileWebURL = [NSURL URLWithString:link];

        }];



        // 버튼

        [textTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {

            buttonBuilder.title = @"자세히 보기";

            buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {

                linkBuilder.mobileWebURL = [NSURL URLWithString:link];

            }];

        }]];

        

    }];

    

    [self.commandDelegate runInBackground:^{

        [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {

            // 성공

            CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        } failure:^(NSError * _Nonnull error) {

            NSLog(@"error: %@",error);

            // 에러

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid arguments"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            

        }];

    }];



}

- (void)shareStory:(CDVInvokedUrlCommand *)command

{

    if (![StoryLinkHelper canOpenStoryLink]) {

        NSLog(@"Cannot open kakao story.");

        // 에러

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"KakaoStory not installed."];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;

    }

    

    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];



    NSString* title = options[@"title"];

    NSString* desc = options[@"desc"];

    NSString* link = options[@"link"];

    NSString* image = options[@"thumb"];

    

    NSBundle *bundle = [NSBundle mainBundle];

    ScrapInfo *scrapInfo = [[ScrapInfo alloc] init];

    scrapInfo.title = title;

    scrapInfo.desc = desc;

    scrapInfo.imageURLs = @[image];

    scrapInfo.type = ScrapTypeArticle;

    

    NSString* post_text =   [NSString stringWithFormat:@"[%@] - %@ %@",title,desc,link];

    NSString *storyLinkURLString = [StoryLinkHelper makeStoryLinkWithPostingText:post_text

                                                                     appBundleID:[bundle bundleIdentifier]

                                                                      appVersion:[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

                                                                         appName:[bundle objectForInfoDictionaryKey:@"CFBundleName"]

                                                                       scrapInfo:scrapInfo];

    

    [self.commandDelegate runInBackground:^{

        [StoryLinkHelper openStoryLinkWithURLString:storyLinkURLString];

    }];

    

}



- (void)share:(CDVInvokedUrlCommand *)command

{

    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];



    KLKTemplate *template = [KLKFeedTemplate feedTemplateWithBuilderBlock:^(KLKFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {



        NSString* title = options[@"title"];

        NSString* desc = options[@"desc"];

        NSString* link = options[@"link"];

        NSString* image = options[@"thumb"];

        NSString* social = options[@"social"];



        // 콘텐츠

        feedTemplateBuilder.content = [KLKContentObject contentObjectWithBuilderBlock:^(KLKContentBuilder * _Nonnull contentBuilder) {

            if(title){

                contentBuilder.title = title;

            }

            if(desc){

                contentBuilder.desc = desc;

            }

            if(image){

                contentBuilder.imageURL = [NSURL URLWithString:image];

            }

            if(link){

                contentBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {

                    linkBuilder.mobileWebURL = [NSURL URLWithString:link];

                }];

            }

        }];

        

        // 소셜

        if(social){

            NSDictionary *socialDic = [social copy];

            feedTemplateBuilder.social = [KLKSocialObject socialObjectWithBuilderBlock:^(KLKSocialBuilder * _Nonnull socialBuilder) {

                if(socialDic[@"like"] && [socialDic[@"like"] integerValue] >0){

                    socialBuilder.likeCount = @([socialDic[@"like"] integerValue]);

                }

                if(socialDic[@"comment"] && [socialDic[@"comment"] integerValue] >0){

                    socialBuilder.commnentCount = @([socialDic[@"comment"] integerValue]);

                }

                if(socialDic[@"view"] && [socialDic[@"view"] integerValue] >0){

                    socialBuilder.viewCount = @([socialDic[@"view"] integerValue]);

                }

                if(socialDic[@"shared"] && [socialDic[@"shared"] integerValue] >0){

                    socialBuilder.sharedCount = @([socialDic[@"shared"] integerValue]);

                }

            }];

        }

        

        // 버튼

        if(link){

            [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {

                buttonBuilder.title = @"자세히 보기";

                buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {

                    linkBuilder.mobileWebURL = [NSURL URLWithString:link];

                }];

            }]];

        }

    }];

    

    [self.commandDelegate runInBackground:^{

        [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {

            // 성공

            CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        } failure:^(NSError * _Nonnull error) {

            NSLog(@"error: %@",error);

            // 에러

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid arguments"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            

        }];

    }];





}



@end
