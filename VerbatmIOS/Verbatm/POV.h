//
//  POV.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POV : NSObject <NSCoding>

@property (strong, nonatomic) NSString* thread;
@property (strong, nonatomic) NSMutableArray* pinchViews;
@property (strong, nonatomic) NSString* creatorName;
@property (strong, nonatomic) NSString* creatorImageName;
@property (strong, nonatomic) NSString* channelName;

-(instancetype) initWithThread: (NSString*)thread andPinchViews: (NSMutableArray*) pinchViews
				andCreatorName:(NSString*) creatorName andCreatorImageName: (NSString*) creatorImageName
				andChannelName:(NSString*) channelName;

@end
