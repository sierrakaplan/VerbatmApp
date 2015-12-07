//
//  POV.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Represents a POV object while it is being created in the ADK

#import "POV.h"

@interface POV()

#define THREAD_KEY @"thread_key"
#define PINCHVIEWS_KEY @"pov_pinchviews_key"
#define CREATOR_NAME_KEY @"creator_name_key"
#define CREATOR_IMAGE_NAME_KEY @"creator_image_name_key"
#define CHANNEL_NAME_KEY @"channel_name_key"

@end

@implementation POV

-(instancetype) initWithThread: (NSString*)thread andPinchViews: (NSMutableArray*) pinchViews
				andCreatorName:(NSString*) creatorName andCreatorImageName: (NSString*) creatorImageName
				andChannelName:(NSString*) channelName {
	if (self = [super init]) {
		self.thread = thread;
		self.pinchViews = pinchViews;
		self.creatorName = creatorName;
		self.creatorImageName = creatorImageName;
		self.channelName = channelName;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.thread forKey:THREAD_KEY];
	[coder encodeObject:self.pinchViews forKey:PINCHVIEWS_KEY];
	[coder encodeObject:self.creatorName forKey:CREATOR_NAME_KEY];
	[coder encodeObject:self.creatorImageName forKey:CREATOR_IMAGE_NAME_KEY];
	[coder encodeObject:self.channelName forKey:CHANNEL_NAME_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.thread = [decoder decodeObjectForKey:THREAD_KEY];
		self.pinchViews = [decoder decodeObjectForKey:PINCHVIEWS_KEY];
		self.creatorName = [decoder decodeObjectForKey:CREATOR_NAME_KEY];
		self.creatorImageName = [decoder decodeObjectForKey:CREATOR_IMAGE_NAME_KEY];
		self.channelName = [decoder decodeObjectForKey:CHANNEL_NAME_KEY];
	}
	return self;
}

@end
