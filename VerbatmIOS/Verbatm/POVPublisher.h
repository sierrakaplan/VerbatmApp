//
//  Uploader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POVPublisher : NSObject

-(instancetype) initWithPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic;

- (void) publish;

@end
