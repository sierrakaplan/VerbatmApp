//
//  Uploader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POVPublisher : NSObject

#define PROGRESS_UNITS_FOR_FINAL_PUBLISH 2
#define PROGRESS_UNITS_FOR_PHOTO 3
#define PROGRESS_UNITS_FOR_VIDEO 10

// initialized once publish has been called
@property(nonatomic, strong) NSProgress* publishingProgress;

-(instancetype) initWithPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic;
- (void) publish;

@end
