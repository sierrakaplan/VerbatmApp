//
//  internetConnectionMonitor.h
//  Verbatm
//
//  Created by Iain Usiri on 8/19/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/*
 This class monitors the internet connection of phone and sends out notifications whenever there is a change in status. You must register for the INTERNET_CONNECTION_NOTIFICATION. Upon receiving the notificaiton check it's user info with key: INTERNET_CONNECTION_KEY to get a bool string with either "YES" for is connected or "NO" for no connection available. 
 */

#import <Foundation/Foundation.h>

@interface InternetConnectionMonitor : NSObject

+ (InternetConnectionMonitor*) sharedInstance;

//tells you if the app is connected to the internet asynchronously;
-(void) isConnectedToInternet_asynchronous;

//tells you the most recent update state
//so this could return true but a new update could occur right after saying there's no connection
//all you know is that this is the state of the most recent update that has occured
//use this in tandem with notifications that send more accurate updates
-(BOOL)isThereConnectivity;
@end
