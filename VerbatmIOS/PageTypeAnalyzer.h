//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PageViewingExperience.h"

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import <PromiseKit/PromiseKit.h>

@class Page;

typedef enum PageTypes{
    PageTypePhoto = 0,
    PageTypeVideo = 1,
    PageTypePhotoVideo = 2,
} PageTypes;

@interface PageTypeAnalyzer : NSObject

-(NSMutableArray*) getPageViewsFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame inPreviewMode: (BOOL) inPreviewMode ;

-(void) getPageViewFromPage: (PFObject *)page withFrame: (CGRect)frame andCompletionBlock:(void(^)(NSArray *))block;

+(PageViewingExperience *) getPageViewFromPageMedia:(NSArray *)pageMedia withFrame:(CGRect)frame;

@end
