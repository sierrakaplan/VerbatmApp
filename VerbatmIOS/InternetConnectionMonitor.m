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
#import "InternetConnectionMonitor.h"
#import "Reachability.h"
#import "Notifications.h"

@interface InternetConnectionMonitor ()
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic) BOOL thereIsConnection;
@property (nonatomic) BOOL justReceivedNoConnectionSignal;//this is to prevent double calls
@property (nonatomic, strong) NSRunLoop* runloop;

#define NO_NETWORK_WAIT_TIME 4 //in seconds - because we get double signals we need to wait to prevent from false positves
@end

@implementation InternetConnectionMonitor


-(instancetype) init{
    self = [super init];
    if(self){
        [self prepareReachabilityInfo];
    }
    return self;
}

+ (InternetConnectionMonitor*) sharedInstance {
	static InternetConnectionMonitor *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[self alloc] init];
	});

	return _sharedInstance;
}

-(void)prepareReachabilityInfo {
    //register to receive notifications whenever the status of connectivity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //start at no
    self.thereIsConnection = NO;
    self.justReceivedNoConnectionSignal = NO;
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


/*
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note{
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
        case NotReachable:{
            //mark there is not internet connection
            //[self weHaveNoConneciton];
            break;
        }
        case ReachableViaWWAN:{
            self.thereIsConnection = YES;
               // [self weHaveConnection];
            break;
        }
        case ReachableViaWiFi:{
                self.thereIsConnection = YES;
              //  [self weHaveConnection];
            //we have conneciton by wifi
            break;
        }
    }
}

//sends out a notification that we have internet connection
-(void)weHaveConnection{
    self.thereIsConnection = YES;
    
    NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], INTERNET_CONNECTION_KEY, nil];
    
    NSNotification *notification = [[NSNotification alloc]initWithName:INTERNET_CONNECTION_NOTIFICATION object:nil userInfo:Info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}

//send out a notificaiton that we have internet connetion
-(void)weHaveNoConneciton{
    //For the second time this function is called not by the timer
    if(self.justReceivedNoConnectionSignal){
        self.thereIsConnection = NO;
    }
    
    if(!self.justReceivedNoConnectionSignal){
        self.justReceivedNoConnectionSignal = YES;
        [NSTimer scheduledTimerWithTimeInterval:NO_NETWORK_WAIT_TIME target:self selector:@selector(timerForNoConnection:) userInfo:nil repeats:NO];
    }else if(!self.thereIsConnection){
        self.justReceivedNoConnectionSignal = NO;
        NSDictionary *Info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], INTERNET_CONNECTION_KEY, nil];
        NSNotification *notification = [[NSNotification alloc]initWithName:INTERNET_CONNECTION_NOTIFICATION object:nil userInfo:Info];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)timerForNoConnection:(NSTimer *)timer{
    if(self.thereIsConnection){
        self.justReceivedNoConnectionSignal = NO;
    }
}

-(void) isConnectedToInternet_asynchronous{
    [self updateInterfaceWithReachability:self.internetReachability];
    [self updateInterfaceWithReachability:self.wifiReachability];
}

#pragma mark - Lazy instantiation -
-(NSRunLoop *)runloop{
    if(!_runloop) _runloop = [[NSRunLoop alloc] init];
    return _runloop;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
