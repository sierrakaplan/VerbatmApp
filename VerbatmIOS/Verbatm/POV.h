//
//  POV.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This class was used in LocalPOVs to store a POV in user defaults, for Matter Demo Day.
//	It is legacy code now but still exists for test purposes if you ever want to test
//	by storing a story locally. A POV is a single post in a user's channel.
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
