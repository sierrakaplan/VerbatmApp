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

-(instancetype) initWithThread: (NSString*)thread andPinchViews: (NSMutableArray*) pinchViews;

@end
