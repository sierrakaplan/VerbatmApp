//
//  internetConnectionMonitor.m
//  Verbatm
//
//  Created by Iain Usiri on 8/19/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


/*
 This class monitors the state of the internet connection (wifi and cell network)
 and notifies the rest of the project on changes
 */
#import "internetConnectionMonitor.h"
#import "Reachability.h"
#import "Notifications.h"

@interface internetConnectionMonitor ()
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic) BOOL thereIsConnection;
@end

@implementation internetConnectionMonitor


-(instancetype) init{
    self = [super init];
    if(self){
        [self prepareReachabilityInfo];
    }
    return self;
}

-(void)prepareReachabilityInfo {
    
    //register to receive notifications whenever the status of connectivity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //start at no
    self.thereIsConnection = NO;
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability{
    [self configureReachability:reachability];
}


/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

/*
    When connectivity is changing this function is called twice. But this isn't too much of an issue
    because these changes are infrequent.
 */
- (void)configureReachability:(Reachability *)reachability {
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus){
        case NotReachable: {
            //there is not internet connection
            [self weHaveNoConneciton];
            break;
        }
        case ReachableViaWWAN:  {
            //we have connection view network
            if(!self.thereIsConnection)[self weHaveConnection];
            break;
        }
        case ReachableViaWiFi:  {
            if(!self.thereIsConnection)[self weHaveConnection];
            //we have conneciton by wifi
            break;
        }
    }
}



//sends out a notification that we have internt connection
-(void)weHaveConnection{
    self.thereIsConnection = YES;
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", INTERNET_CONNECTION_KEY, nil];
    NSNotification *notification = [[NSNotification alloc]initWithName:INTERNET_CONNECTION_NOTIFICATION object:nil userInfo:Info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}

//send out a notificaiton that we have internet connetion
-(void)weHaveNoConneciton{
    self.thereIsConnection = NO;
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:@"NO", INTERNET_CONNECTION_KEY, nil];
    NSNotification *notification = [[NSNotification alloc]initWithName:INTERNET_CONNECTION_NOTIFICATION object:nil userInfo:Info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}



@end
