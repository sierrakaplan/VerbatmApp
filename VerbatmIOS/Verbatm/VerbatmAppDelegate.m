//
//  verbatmAppDelegate.m
//  Verbatm
//
//  Created by Iain Usiri on 8/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmAppDelegate.h"

#import "Analytics.h"

#import "InstallationVariables.h"

#import "Notifications.h"

#import "UserManager.h"

#pragma mark Frameworks

#import <AVFoundation/AVFoundation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "PostInProgress.h"
#import <PromiseKit/PromiseKit.h>

#import <Crashlytics/Crashlytics.h>
#import <Branch/Branch.h>
#import <Fabric/Fabric.h>

@implementation VerbatmAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	// Check if the app is launching from a push notification
	NSDictionary *pushNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (pushNotification) {
		//todo: deep link? do something better than a global var
		[InstallationVariables sharedInstance].launchedFromNotification = YES;
	} else {
		[InstallationVariables sharedInstance].launchedFromNotification = NO;
	}

	// Limit cache size
	int cacheSizeMemory = 15*1024*1024; // 4MB
	int cacheSizeDisk = 32*1024*1024; // 32MB
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
	[NSURLCache setSharedURLCache:sharedCache];

	// Load post in adk
	[[PostInProgress sharedInstance] loadPostFromUserDefaults];

	// Set up parse
	[self setUpParseWithLaunchOptions: launchOptions];
	PMKSetUnhandledExceptionHandler(^NSError * _Nullable(id exception) {
		return [NSError errorWithDomain:PMKErrorDomain code:PMKUnexpectedError
							   userInfo:nil];
	});
	[[Analytics getSharedInstance] newUserSession];

	// Fabric (and Optimizely, if needed can bring back)
	[Fabric with:@[[Crashlytics class]]];
	//    	[Optimizely startOptimizelyWithAPIToken: @"AANIfyUBGNNvR9jy_iEWX8c97ahEroKr~3788260592" launchOptions:launchOptions];


	// Register for Push notifications
	UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
													UIUserNotificationTypeBadge |
													UIUserNotificationTypeSound);
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																			 categories:nil];
	[application registerUserNotificationSettings:settings];

	// Branch.io (for external share links)
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
			NSLog(@"Error setting up branch: %@", error.description);
		}

		[branch setNetworkTimeout:5]; //timeout after 5 seconds
		[branch setRetryInterval:5];
		[branch setMaxRetries:1];
    }];

	// Call fb sdk method
	return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
	//register to receive notifications
	[application registerForRemoteNotifications];
}

// Call back method for registering for push notifications. Save device token in parse.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	currentInstallation.channels = @[ @"global" ];
	[currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	NSLog(@"Error in registration. Error: %@", err);
	[[Crashlytics sharedInstance] recordError:err];
	//todo: handle the fact that app will not receive notifications
}

// Method that handles push notifications when app is active
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_NEW_PUSH_NOTIFICATION object:nil userInfo:userInfo];
	[[NSNotificationCenter defaultCenter] postNotification: notification];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(void) setUpParseWithLaunchOptions: (NSDictionary*)launchOptions {
	// [Optional] Power your app with Local Datastore. For more info, go to
	// https://parse.com/docs/ios_guide#localdatastore/iOS
	//[Parse enableLocalDatastore];
	// Initialize Parse.
	ParseClientConfiguration *config  = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
		configuration.applicationId = @"rzSvJWHhiN8KUnhDVXTlapJkJ4eCe3xAlmEscSK3";
		configuration.clientKey = @"qmXzBTKKMNqm5A3eogopkL2ZY6SeKGcWah0zP9kk";
		configuration.server = @"https://serene-everglades-29931.herokuapp.com/";
	}];
	[Parse initializeWithConfiguration:config];

	// [Optional] Track statistics around application opens.
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

	[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
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

// Facebook login code
- (BOOL)application:(UIApplication *)application
			openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
		 annotation:(id)annotation {
    
    [[Branch getInstance] handleDeepLink:url];
	return [[FBSDKApplicationDelegate sharedInstance] application:application
														  openURL:url
												sourceApplication:sourceApplication
													   annotation:annotation];
}

@end
