//
//  PovInfo.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.

//	Wrapper class for the GTLVerbatmAppPOVInfo downloaded from the cloud
//	so that it can store the actual data for a cover photo
//

#import <Foundation/Foundation.h>
#import "GTLVerbatmAppPOVInfo.h"

@interface PovInfo : GTLVerbatmAppPOVInfo

-(instancetype) initWithGTLVerbatmAppPovInfo: (GTLVerbatmAppPOVInfo*) gtlPovInfo andCoverPhoto: (UIImage*) coverPhoto;

@property (strong, nonatomic) UIImage* coverPhoto;

@end
