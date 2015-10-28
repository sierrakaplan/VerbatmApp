//
//  verbatmAppDelegate.m
//  Verbatm
//
//  Created by Iain Usiri on 8/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmAppDelegate.h"
#import "Analytics.h"
#import "UserPovInProgress.h"
#import <AVFoundation/AVFoundation.h>
#import "UserSetupParameters.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <PromiseKit/PromiseKit.h>

@implementation VerbatmAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[self setUpParseWithLaunchOptions: launchOptions];

	PMKSetUnhandledExceptionHandler(^NSError * _Nullable(id exception) {
		return [NSError errorWithDomain:PMKErrorDomain code:PMKUnexpectedError
							   userInfo:nil];
	});

    [[UserSetupParameters sharedInstance] setUpParameters];//this sets up
	[[UserPovInProgress sharedInstance] loadPOVFromUserDefaults];
    
    [[Analytics getSharedInstance] newUserSession];

    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void) setUpParseWithLaunchOptions: (NSDictionary*)launchOptions {
	// [Optional] Power your app with Local Datastore. For more info, go to
	// https://parse.com/docs/ios_guide#localdatastore/iOS
	[Parse enableLocalDatastore];
	// Initialize Parse.
	[Parse setApplicationId:@"rzSvJWHhiN8KUnhDVXTlapJkJ4eCe3xAlmEscSK3"
				  clientKey:@"qmXzBTKKMNqm5A3eogopkL2ZY6SeKGcWah0zP9kk"];

	// [Optional] Track statistics around application opens.
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

	[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
}

// NOT IN USE
-(void) customizeTabBarAppearance {
	UIImage *whiteBackground = [UIImage imageNamed:@"blackBackground"];
	[[UITabBar appearance] setSelectionIndicatorImage:whiteBackground];
}

//logs that the app was just opened
-(void) logAppOpenAnalyticsWithOptions:(NSDictionary *)launchOptions{
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}



							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
   [[Analytics getSharedInstance] endOfUserSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[Analytics getSharedInstance] newUserSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UserSetupParameters sharedInstance] saveAllChanges];
}

// Facebook login code
- (BOOL)application:(UIApplication *)application
			openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
		 annotation:(id)annotation {
	return [[FBSDKApplicationDelegate sharedInstance] application:application
														  openURL:url
												sourceApplication:sourceApplication
													   annotation:annotation];
}

@end
