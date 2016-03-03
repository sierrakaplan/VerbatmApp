//
//  VideoManager.m
//  Verbatm
//
//  Created by Iain Usiri on 11/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VideoManager.h"

@interface VideoManager ()




@end


@implementation VideoManager

/*
 Get access to the singleton
 */
+(instancetype) sharedInstance {
    static VideoManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoManager alloc] init];
    });
    return sharedInstance;
}

@end
