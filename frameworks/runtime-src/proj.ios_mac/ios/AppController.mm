/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "CCLuaBridge.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GAI.h"

@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;
static RootViewController *s_rootViewController;
static int s_adCallbackID;
static AppController *s_appController;
static NSDictionary *localNotificationMemo = nil;

GADBannerView *banner;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    s_appController = self;
    [AdColony configureWithAppID: @"appcc91c8db46e0439a83"
                         zoneIDs: @[@"vze85d3eca448840c181"]
                        delegate: self
                         logging: YES];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-6829985-10"];

    cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                     pixelFormat: (NSString*)cocos2d::GLViewImpl::_pixelFormat
                                     depthFormat: cocos2d::GLViewImpl::_depthFormat
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [eaglView setMultipleTouchEnabled:YES];
    
    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;
    s_rootViewController = viewController;

    banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(([UIScreen mainScreen].bounds.size.width - kGADAdSizeBanner.size.width) / 2, -kGADAdSizeBanner.size.height)];
    banner.adUnitID = @"ca-app-pub-9353254478629065/9695133034";
    banner.rootViewController = viewController;
    [viewController.view addSubview:banner];
    GADRequest *req = [GADRequest request];
#ifdef DEBUG
    req.testDevices = @[@"222a73cb790e1c8aea3fe4fcbee5538a", @"d4bd2d366be0f2ae169015eaf3ce4714"];
#endif
    [banner loadRequest:req];

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];

    //[[UIApplication sharedApplication] setStatusBarHidden: YES];

    [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController* vc, NSError* err) {
        if (vc != nil) {
            [viewController presentViewController:vc animated:YES completion:nil];
        }
    };

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    app->run();
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [AppController localNotificationImpl];
    }
}

- (void)dealloc {
    [super dealloc];
}

+ (void)share:(NSDictionary*)args
{
    UIActivityViewController *av = [[UIActivityViewController alloc] initWithActivityItems:@[args[@"text"], [UIImage imageWithContentsOfFile:args[@"image"]]] applicationActivities:nil];
    if ([av respondsToSelector:@selector(popoverPresentationController)]) {
        av.popoverPresentationController.sourceView = s_rootViewController.view;
    }
    [s_rootViewController presentViewController:av animated:YES completion:nil];
}

+ (void)reward:(NSDictionary*)args {
    s_adCallbackID = [args[@"callback"] intValue];
    [AdColony playVideoAdForZone:@"vze85d3eca448840c181"
                    withDelegate:nil
                withV4VCPrePopup:NO
                andV4VCPostPopup:NO];
}

- (void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
    cocos2d::LuaBridge::pushLuaFunctionById(s_adCallbackID);
    cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack();
    stack->pushString(success ? "success" : "fail");
    stack->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(s_adCallbackID);
}

+ (void)bannerAd:(NSDictionary*)args {
    float x = ([UIScreen mainScreen].bounds.size.width - kGADAdSizeBanner.size.width) / 2;
    if ([args[@"show"] boolValue]) {
        [UIView animateWithDuration:0.2 animations:^{
            banner.frame = CGRectMake(x, [UIApplication sharedApplication].statusBarFrame.size.height, banner.frame.size.width, banner.frame.size.height);
        }];
    } else {
        banner.frame = CGRectMake(x, -banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
    }
}

+ (void)reportScore:(NSDictionary*)args {
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    }
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:args[@"board"]];
    score.value = [args[@"score"] longLongValue];
    [GKScore reportScores:@[score] withCompletionHandler:nil];
}

+ (void)showBoard:(NSDictionary*)args {
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    }
    GKGameCenterViewController *vc = [[GKGameCenterViewController alloc] init];
    vc.viewState = GKGameCenterViewControllerStateLeaderboards;
    vc.leaderboardIdentifier = args[@"id"];
    vc.gameCenterDelegate = s_appController;
    [s_rootViewController presentViewController:vc animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

+ (void)localNotification:(NSDictionary *)args
{
    localNotificationMemo = args;
    [localNotificationMemo retain];
    NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
    if([currentVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // i0S7
        [AppController localNotificationImpl];
    } else {
        // iOS8
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge categories:nil]];
        } else {
            [AppController localNotificationImpl];
        }
    }
}

+ (void)localNotificationImpl
{
    if (localNotificationMemo == nil) {
        return;
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[localNotificationMemo[@"sec"] intValue]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = localNotificationMemo[@"body"];
    notification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [localNotificationMemo release];
    localNotificationMemo = nil;
}

@end
