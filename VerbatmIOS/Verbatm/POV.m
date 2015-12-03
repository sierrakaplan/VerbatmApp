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

@end

@implementation POV

-(instancetype) initWithThread: (NSString*)thread andPinchViews: (NSMutableArray*) pinchViews {
	if (self = [super init]) {
		self.thread = thread;
		self.pinchViews = pinchViews;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.thread forKey:THREAD_KEY];
	[coder encodeObject:self.pinchViews forKey:PINCHVIEWS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.thread = [decoder decodeObjectForKey:THREAD_KEY];
		self.pinchViews = [decoder decodeObjectForKey:PINCHVIEWS_KEY];
	}
	return self;
}

@end
