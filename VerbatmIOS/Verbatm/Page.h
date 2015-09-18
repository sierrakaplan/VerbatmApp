//
//  Page.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Page : NSObject

@property (nonatomic) NSInteger indexInPOV;

// Array of GTLVerbatmAppImage
@property (nonatomic, strong) NSArray *images;
// Array of Video
@property (nonatomic, strong) NSArray *videos;

@end
